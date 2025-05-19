import RxSwift
import RxCocoa

class DeliveryRecordViewModel: PaginationViewModel<ShipListEnvelope.ShipInfo> {

    var viewDidLoadTrigger = PublishSubject<Void>()
    
    var getShipWorthRequest = PublishSubject<Void>()
    var shipWorthEnvelope = PublishSubject<ShipWorthEnvelope>()

    init(status: DeliveryStatus) {
		super.init()
        // 列表数据
        let response =
            Observable.merge(request, viewDidLoadTrigger.mapTo(1))
            .flatMapLatest { page in
                AppEnvironment.current.apiService.getShipList(status: status.rawValue, page: page).materialize()
        	}
        	.share(replay: 1)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.shipList
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
        
        // 订单数据
        let shipWorthResponse = getShipWorthRequest.asObservable().flatMapLatest { _ in
                AppEnvironment.current.apiService.getShipCountAndWorth().materialize()
            }
            .share(replay: 1)
        
        shipWorthResponse.elements()
            .bind(to: shipWorthEnvelope)
            .disposed(by: disposeBag)

        Observable.merge(shipWorthResponse.errors(), response.errors())
//        response.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
