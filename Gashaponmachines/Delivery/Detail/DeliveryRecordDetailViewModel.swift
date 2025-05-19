import RxCocoa
import RxSwift

class DeliveryRecordDetailViewModel: BaseViewModel {
    var refreshTrigger = PublishSubject<Void>()
    var shipDetail = PublishRelay<ShipDetailEnvelope>()
    var confirmReceive = PublishRelay<ResultEnvelope>()
    var submitSignal = PublishSubject<Void>()

    init(shipId: String) {
        super.init()

        let response = self.refreshTrigger.asObservable()
            .flatMapLatest {
                AppEnvironment.current.apiService.getShipDetail(shipId: shipId).materialize()
            }
            .share(replay: 1)

        response
            .elements()
        	.bind(to: shipDetail)
        	.disposed(by: disposeBag)

        let confirmResponse = self.submitSignal.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.confirmReceive(shipId: shipId).materialize()
        	}
            .share(replay: 1)

        confirmResponse.elements()
        	.bind(to: confirmReceive)
        	.disposed(by: disposeBag)

        Observable.merge(
        	response.errors(),
            confirmResponse.errors()
        )
        .requestErrors()
        .bind(to: error)
        .disposed(by: disposeBag)
    }
}
