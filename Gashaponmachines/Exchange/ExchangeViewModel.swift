import RxCocoa
import RxSwift
import RxDataSources

typealias ExchangeProductSelectedState = (index: Int, products: [EggProduct])

enum ExchangeSelectionEvent {
    // 在外面选择或取消选择
    case outterSelection(indexPath: IndexPath, products: [EggProduct])
    // 在里面选择或取消选择
    case innerSelection(indexPath: IndexPath, products: [EggProduct])

    case all([[EggProduct]?])
}

typealias ExchangeInfo = (totalCount: Int, totalValue: Int)
let seed = [[EggProduct]?](repeating: nil, count: 30)

struct ExchangeViewModel {

    let refreshTrigger = PublishSubject<Void>()
    let viewWillAppearTrigger = PublishSubject<Void>()

    var envelope: Driver<[EggExchangeListEnvelope]>
    // drive by the modelSelected method

    // bind to cell for selected UI configuration
    var selectionState = BehaviorSubject<[[EggProduct]?]>(value: [[EggProduct]?](repeating: nil, count: 30))
    // 准备兑换的数量
    var totalValue = BehaviorRelay<Int>(value: 0)
    // 换碎片后的结果
    var exchangeResult: Driver<ExchangeEggPointEnvelope>

    var selection = PublishSubject<ExchangeSelectionEvent>()

    // 兑换蛋壳事件
    var exchangeButtonSubject = PublishSubject<Void>()

	var disposedBag = DisposeBag()

    var error: Observable<ErrorEnvelope>

    var allProducts = PublishSubject<[([EggProduct]?, String)]>()
    var noneSelectedTypes = BehaviorRelay<[String]>(value: [])

    var totalCount = BehaviorRelay<Int>(value: 0)

    var exchangeInfo: Driver<ExchangeInfo>

    init(type: EggProductType) {

        self.selection
            .asObservable()
            .scan(seed) { (acc: [[EggProduct]?], event: ExchangeSelectionEvent) in

                // 选中的逻辑，什么时候应该选中：点击对应蛋壳collectionview cell 的时候
                // 不选中的逻辑，什么时候应该不选中：(1)点击已选中的蛋壳 colelctionview 的时候
                // (2) 点进去详情把所有商品取消选中的时候
                var acc = acc
                switch event {
                case .outterSelection(let indexPath, let products): // 外部选中
                    // 如果之前不存在，那就选中
                    if acc[indexPath.row] == nil {
                        acc[indexPath.row] = products
                    } else {
                        acc[indexPath.row] = nil
                    }
                    // 商品个数为0, 则为不选中
                    if products.count == 0 {
                        acc[indexPath.row] = nil
                    }
                case .innerSelection(let indexPath, let products): // 内部选中
                    if products.isEmpty {
                        acc[indexPath.row] = nil
                    } else {
                        acc[indexPath.row] = products
                    }
                case .all(let array):
                    acc = array
                }

                return acc
        	}
        	.startWith(seed)
            .bind(to: self.selectionState)
        	.disposed(by: disposedBag)

        // 拉取列表
        let listResponse = Observable
            .merge(
            	self.viewWillAppearTrigger.asObservable(),
            	self.refreshTrigger.asObservable()
            )
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getUserExchangeEggProducts(sourceType: type.rawValue).materialize()
        	}
            .share(replay: 1)

        self.envelope = listResponse
            .elements()
            .map { [$0] }
            .asDriver(onErrorJustReturn: [])

        // 准备兑换的 orderIds
        let willExchangeOrderIds = self.selectionState.map {
            $0
            .compactMap { $0 }
            .flatMap { $0 }
            .compactMap { $0.orderId }
        }

        listResponse
            .elements()
            .map { $0.noneSelectedEggTypes}
            .bind(to: noneSelectedTypes)
            .disposed(by: disposedBag)

        listResponse
            .elements()
            .map { $0.eggs.map { ($0.products, $0.type) } }
            .bind(to: allProducts)
            .disposed(by: disposedBag)

        // 总数
        self.selectionState
            .map { $0.compactMap { $0 }.flatMap { $0 }.reduce(0) { $0 + Int($1.worth ?? "0")!} }
        	.bind(to: totalValue)
        	.disposed(by: disposedBag)

        self.selectionState
            .map { $0.compactMap { $0 }.flatMap { $0 }.count }
        	.bind(to: totalCount)
        	.disposed(by: disposedBag)

        // 兑换结果
        let resultResponse = exchangeButtonSubject.asObservable()
            .withLatestFrom(willExchangeOrderIds)
//            .map { ids in
//                var idArray = [String]()
//                for index in 0...499 {
//                    let id = ids[index]
//                    idArray.append(id)
//                }
//                return idArray
//            }
            .flatMapLatest { orderIds in
                AppEnvironment.current.apiService.exchangeEggPoints(orderIds: orderIds).materialize()
            }
            .share(replay: 1)

        self.exchangeInfo = Observable
            .zip(totalCount, totalValue)
            .map { (totalCount: $0.0, totalValue: $0.1)}
        	.asDriver(onErrorDriveWith: .never())

        self.exchangeResult = resultResponse
            .elements()
            .asDriver(onErrorDriveWith: .never())

        self.error = Observable
            .merge(
            	listResponse.errors().requestErrors(),
        		resultResponse.errors().requestErrors()
    		)
    }
}

extension EggExchangeListEnvelope: SectionModelType {

    public var items: [Egg] {
        return self.eggs
    }

    public init(original: EggExchangeListEnvelope, items: [Egg]) {
        self = original
    }

    public typealias Item = Egg
}
