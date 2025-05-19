import RxSwift
import RxCocoa

class MallViewModel: BaseViewModel {
    /// 商品分类数据
    var collections = BehaviorRelay<[MallCollection]>(value: [])

    /// 头部数据
    var mallInfo = PublishSubject<MallInfoV2Envelope>()

    /// 视图即将出现
    var viewWillAppearTrigger = PublishSubject<()>()

    /// 选中某个商品分类
//    var selectedCollection = BehaviorRelay<String?>(value: nil)

    override init() {
        super.init()

        let getCollectionsResp =
            self.viewWillAppearTrigger.asObservable()
                .flatMapLatest { _ in
                    AppEnvironment.current.apiService.getMallInfoV2(page: 1).materialize()
                }
                .share(replay: 1)

        getCollectionsResp
            .elements()
            .bind(to: mallInfo)
            .disposed(by: disposeBag)

        getCollectionsResp
            .elements()
            .map { $0.collections }
            .bind(to: collections)
            .disposed(by: disposeBag)
    }
}

class MChildViewModel: PaginationViewModel<MallProduct> {

    init(mallCollectionId: String) {
        super.init()

        let response = request
        .flatMapLatest { AppEnvironment.current.apiService.getMallCollectionProductList(mallCollectionId: mallCollectionId, page: $0).materialize()
        }
        .share(replay: 1)

        Observable
            .merge(request.map { _ in true },
                   response.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, products in
                let responseMachines = res.products
                self.isEnd.accept(responseMachines.count < Constants.kDefaultPageLimit)
                return self.pageIndex == Constants.kDefaultPageIndex ? responseMachines : products + responseMachines
            }
            .sample(response.elements())
            .bind(to: items)
            .disposed(by: disposeBag)

        response.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
