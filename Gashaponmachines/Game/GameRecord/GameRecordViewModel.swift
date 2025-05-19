import RxCocoa
import RxSwift
import RxSwiftExt

class GameRecordViewModel: PaginationViewModel<GameRecordEnvelope.GameRecord> {

    var types = PublishRelay<[GameRecordEnvelope.GameRecordType]>()

    var selectedType = BehaviorRelay<Int>(value: 0)

    override init() {
		super.init()

        self.selectedType
            .subscribe(onNext: { _ in
                self.pageIndex = 1
            })
            .disposed(by: disposeBag)

        let response = Observable
            .combineLatest(self.selectedType.asObservable(), request)
            .flatMapLatest { pair in
                AppEnvironment.current.apiService.getGameRecords(machineType: pair.0, page: pair.1).materialize()
            }
            .share(replay: 1)

        response.elements()
            .map { $0.types }
        	.bind(to: types)
        	.disposed(by: disposeBag)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.records
                self.isEnd.accept(responseMachines.count < Constants.kDefaultPageLimit)
                return self.pageIndex == Constants.kDefaultPageIndex ? responseMachines : array + responseMachines
            }
            .sample(response.elements())
            .bind(to: items)
            .disposed(by: disposeBag)

        Observable
            .merge(request.map { _ in true },
                   response.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)

        response
            .errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
