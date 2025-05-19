import RxSwift
import RxCocoa

class YiFanShangViewModel: PaginationViewModel<YiFanShangItem> {

//    var selectedType = BehaviorRelay<YiFanShangTableHeaderViewButtonType>(value: YiFanShangTableHeaderViewButtonType.yiFanShang(type: YiFanShangSegmentType.recommend))

//    var rules = BehaviorRelay<[String]>(value: [])
    
    var selectedType = BehaviorRelay<YiFanShangSegmentType>(value: .recommend)
    
    var linkUrl: String?

    override init() {
        super.init()

        // 点击 HeaderView 规则说明 按钮
//        let ruleResponse = selectedType.filter { $0.indexValue == 2 }
//            .flatMapLatest { _ in
//                AppEnvironment.current.apiService.getOnePieceRules().materialize()
//            }
//            .share(replay: 1)

        // 分页请求
//        let paginationResp = Observable.combineLatest(
//            selectedType.filter { $0.indexValue != 2 },
//            request
//            )
//            .map { (type: $0.0, page: $0.1) }
//            .flatMapLatest { pair -> Observable<Event<YiFanShangRecordListEnvelope>> in
//                switch pair.type {
//                case let .yiFanShang(type):
//                    return AppEnvironment.current.apiService.getOnePieceTaskRecordList(sortBy: type.rawValue,
//                                                                                       sequence: YiFanShangSegmentView.order,
//                                                                                       page: pair.page).materialize()
//                case let .myYiFanShang(type):
//                    return AppEnvironment.current.apiService.getMyOnePieceOrder(type: type.rawValue, page: pair.page).materialize()
//                // 这种情况是不可能发生的，因为上面已经filter掉了
//                case .rule:
//                    let event = Event<YiFanShangRecordListEnvelope>.next(YiFanShangRecordListEnvelope(items: [], isEnd: "1"))
//                    return Observable.just(event)
//                }
//            }
//            .share(replay: 1)
        
        let paginationResp = Observable.combineLatest(selectedType, request)
            .flatMapLatest { pair in
                return AppEnvironment.current.apiService.getOnePieceTaskRecordList(sortBy: pair.0.rawValue, sequence: YiFanShangSegmentView.order, page: pair.1).materialize()
            }
            .share(replay: 1)

//        ruleResponse.elements()
//            .map { $0.rules }
//            .bind(to: rules)
//            .disposed(by: disposeBag)
//
//        ruleResponse.elements()
//            .map { $0.detailsLink }
//            .subscribe(onNext: { link in
//                self.linkUrl = link.action
//            })
//            .disposed(by: disposeBag)

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
//                   ruleResponse.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)
    }
}
