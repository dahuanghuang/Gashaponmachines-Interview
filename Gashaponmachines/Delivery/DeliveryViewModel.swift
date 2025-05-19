import RxSwift
import RxCocoa
import RxSwift
import RxSwiftExt

enum DeliverySelectionEvent {
    // 一个一个地选 (除了有集合的商品除外)
    case product((EggProduct, IndexPath))
    // 一次全选或者取消全选
    case all(Set<EggProduct>)
}

class DeliveryViewModel: PaginationViewModel<EggProduct> {

    // 是否全选
    var isSelectedAll = BehaviorRelay<Bool>(value: false)

    // 选中的状态
    var state = BehaviorRelay<Set<EggProduct>>(value: Set())

    // 自动选择（指点击 cell 后自动显示选中状态）
    var selectedSubject = PublishSubject<(EggProduct, IndexPath)>()

    // 手动选择 （需要手动去显示选中状态）
    var manualSelectedSubject = PublishSubject<(EggProduct, IndexPath)>()

    // 是否选中全部
    var selectedAllSubject = PublishSubject<Bool>()

    // 发货所需元气
    var totalMoneyInfo = BehaviorRelay<(money: Int, shipInfo: EggProductListEnvelope.ShipInfo?)>(value: (0, nil))

    // 选中的物品的 Id
    var confirmItemsIds = BehaviorRelay<[String]>(value: [])

    // 选中物品的数量
    var totalItemCount = BehaviorRelay<Int>(value: 0)

    // 选择的颜色
    var types = BehaviorRelay<[EggProductListEnvelope.ProductType]>(value: [])

    // 全选按钮
    var selectAllButtonTap = PublishRelay<Void>()

    // 选择类型
    var selectedTypeTrigger = BehaviorSubject<Int>(value: 0)

    // 全选时显示所有集合弹窗
    var showSelectionPopup = BehaviorSubject<[(EggProduct, IndexPath)]>(value: [])

    override init() {

        super.init()

        let response = Observable
            .combineLatest(self.selectedTypeTrigger, request)
            .flatMapLatest { pair in
                AppEnvironment.current.apiService.getEggProductList(sourceType: nil, type: pair.0, page: pair.1).materialize()
            }
            .share(replay: 1)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, deliveries in
                let responseMachines = res.products
                self.isEnd.accept(responseMachines.count < 80)
                return self.pageIndex == Constants.kDefaultPageIndex ? responseMachines : deliveries + responseMachines
            }
            .sample(response.elements())
            .bind(to: items)
            .disposed(by: disposeBag)

        // 取消全选
        let unselectAll = selectedAllSubject.asObservable().filter { !$0 }

        // 全选
        let selectAll = selectedAllSubject.asObservable().filter { $0 }

        // 全选普通商品
        let selectAllProductsWithoutCollection = selectAll
            .withLatestFrom(items)
            .map { $0.filter { $0.collections == nil } + self.state.value.filter { $0.collections != nil }}

        // 全选集合商品
        let selectAllProductsWithCollection = selectAll
            .withLatestFrom(items)
            .map {
                zip($0, $0.indices)
                    // 将不是集合的商品过滤掉
                    .filter { $0.0.collections != nil }
                    // 将已经选中的商品过滤掉
                    .filter { !self.state.value.contains($0.0) }
                    // map 成想要的格式
                    .map { ($0.0, IndexPath(row: $0.1, section: 0))}
            }

        // 普通商品
        let normalProduct = selectedSubject.asObservable().filter { $0.0.collections == nil }

        // 合集商品
        let collectionProduct = selectedSubject.asObservable().filter { $0.0.collections != nil }

        // 未选中的集合商品
        let unselectedCollectionProduct = collectionProduct.filter { !self.state.value.contains($0.0) }

        // 选中的集合商品
        let selectedCollectionProduct = collectionProduct.filter { self.state.value.contains($0.0) }

        // 什么时候显示合集选择弹窗
        Observable.merge(
            // 1. 全选的时候
            selectAllProductsWithCollection,
            // 2. 单选合集商品，而且没有被选中的状态下
            unselectedCollectionProduct.map { [$0] }
        	)
        	.bind(to: showSelectionPopup)
        	.disposed(by: disposeBag)

        // 选择状态
        Observable
            .of(
                // 已经选中的集合商品
                selectedCollectionProduct
                    .map { DeliverySelectionEvent.product($0) },
                // 弹窗关闭后手动选中
                manualSelectedSubject
                    .map { DeliverySelectionEvent.product($0) },
                // 不是集合的商品自动选中或取消选中
                normalProduct
                    .map { DeliverySelectionEvent.product($0) },
                // 取消选中所有
                unselectAll
                    .map { _ in DeliverySelectionEvent.all(Set()) },
                // 选中除了集合以外的商品
                selectAllProductsWithoutCollection
                    .map { DeliverySelectionEvent.all(Set($0)) }
        	)
            .merge()
            .scan(Set()) { (acc: Set<EggProduct>, event: DeliverySelectionEvent) in
                var acc = acc
                switch event {
                case .product(let item):
                    if acc.contains(item.0) {
                        acc.remove(item.0)
                    } else {
                        acc.insert(item.0)
                    }
                case .all(let all):
                    acc = all
                }
                return acc
            }
            .startWith(Set())
            .bind(to: state)
            .disposed(by: disposeBag)

        // 是否为全选状态
        Observable
            .combineLatest(
                self.state.map { $0.count },
                self.items.filterEmpty().map { $0.count }
            )
            .map { $0.0 == $0.1 }
            .bind(to: isSelectedAll)
            .disposed(by: disposeBag)

        self.state
            .map { Array($0).count }
            .bind(to: totalItemCount)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                self.state.map { Array($0).compactMap { Int($0.worth ?? "") }.reduce(0, +) }.asObservable(),
           	 	response.elements().map { $0.ship }
        	)
            .map { (money: $0.0, shipInfo: $0.1) }
            .bind(to: totalMoneyInfo)
            .disposed(by: disposeBag)

        Observable
            .merge(request.map { _ in true },
                   response.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)

        self.state
            .map { Array($0).compactMap { $0.orderId } }
            .bind(to: confirmItemsIds)
            .disposed(by: disposeBag)

        response
            .elements()
            .map { $0.typeList }
            .bind(to: types)
            .disposed(by: disposeBag)
    }
}
