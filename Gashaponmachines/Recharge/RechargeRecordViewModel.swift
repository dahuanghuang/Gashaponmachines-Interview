import RxCocoa
import RxSwift

class RechargeRecordViewModel: PaginationViewModel<BalanceLogEnvelope.BalanceLog> {

    override init() {
		super.init()

        let response = request
            .flatMapLatest { page in
                AppEnvironment.current.apiService.getBalanceLog(page: page).materialize()
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
                let responseMachines = res.logs
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
