import RxSwift
import RxCocoa
import RxSwiftExt

class AddressListViewModel: PaginationViewModel<DeliveryAddress> {

    var setDefaultTrigger = PublishSubject<String>()
    var setDefaultResult = PublishSubject<Bool>()
    var selectedSubject = PublishSubject<String>()

    override init() {
		super.init()
        let response = request
            .flatMapLatest { page in
                AppEnvironment.current.apiService.getShipAddressList(page: page).materialize()
        	}
        	.share(replay: 1)

        let setShipAddressDefaultResult = self.setDefaultTrigger.asObservable()
            .flatMapLatest { addressId in
            	AppEnvironment.current.apiService.setShipAddressDefault(addressId: addressId).materialize()
        	}
        	.share(replay: 1)

        setShipAddressDefaultResult
            .elements()
            .map { $0.code == "0" }
            .bind(to: setDefaultResult)
        	.disposed(by: disposeBag)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.addressList
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

        Observable.merge(response.errors(), setShipAddressDefaultResult.errors())
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)

    }
}
