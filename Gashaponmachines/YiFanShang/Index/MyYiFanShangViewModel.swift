import RxSwift
import RxCocoa

class MyYiFanShangViewModel: PaginationViewModel<YiFanShangItem> {
    
    var selectedType = BehaviorRelay<MyYiFanShangSegmentType>(value: .all)
    
    var linkUrl: String?

    override init() {
        super.init()
        
        let paginationResp = Observable.combineLatest(selectedType, request)
            .flatMapLatest { pair in
                return AppEnvironment.current.apiService.getMyOnePieceOrder(type: pair.0.rawValue, page: pair.1).materialize()
            }
            .share(replay: 1)

        paginationResp.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(request, paginationResp.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.items

                self.isEnd.accept(res.isEnd == "1" ? true : false)

                return self.pageIndex == Constants.kDefaultPageIndex ? responseMachines : array + responseMachines
            }
            .sample(paginationResp.elements())
            .bind(to: items)
            .disposed(by: disposeBag)

        Observable
            .merge(request.map { _ in true },
                   paginationResp.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)
    }
}

