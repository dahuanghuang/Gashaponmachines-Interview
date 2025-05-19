import RxCocoa
import RxSwift

class CompositionRecordViewModel: PaginationViewModel<ComposeRecord> {

    var envelope = PublishRelay<ComposeRecordListEnvelope>()

    var totalSavingCount = BehaviorRelay<String>(value: "0")

    override init() {
        super.init()
        // 请求 Response

        let response =
            self.request
                .flatMapLatest { page in
                    AppEnvironment.current.apiService.getComposeRecordList(page: page).materialize()
                }
                .share(replay: 1)

        response.elements()
            .bind(to: envelope)
            .disposed(by: disposeBag)

        envelope.map { "\(abs($0.totalSavingCount))" }
        	.bind(to: totalSavingCount)
        	.disposed(by: disposeBag)

        Observable
            .merge(request.map { _ in true },
                   response.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, products in
                let paths = res.records
                self.isEnd.accept(paths.count < Constants.kDefaultPageLimit)
                return self.pageIndex == Constants.kDefaultPageIndex ? paths : products + paths
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
