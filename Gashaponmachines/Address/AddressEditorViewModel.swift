import RxCocoa
import RxSwiftExt
import RxSwift

typealias UpsertShipAddressParameter = (name: String, phone: String, proviceCode: String, cityCode: String, districtCode: String, detail: String)

struct AddressEditorViewModel {
    var param = PublishSubject<UpsertShipAddressParameter>()
    var result: Driver<DeliveryAddress>
    var viewWillAppearTrigger = PublishSubject<Void>()
    var addressDetail: Driver<DeliveryAddressDetail>
    var error: Observable<ErrorEnvelope>

    init(addressId: String?) {

        let getAddressResponse = self.viewWillAppearTrigger.asObserver()
            .withLatestFrom(Observable.just(addressId))
            .filterNil()
            .flatMapLatest { addressId in
                AppEnvironment.current.apiService.getShipAdddress(addressId: addressId).materialize()
            }
            .share(replay: 1)

        self.addressDetail = getAddressResponse
                .elements()
        		.asDriver(onErrorDriveWith: .never())

        let updateAddressResponse = self.param
            .asObservable()
            .flatMapLatest { param in
            	AppEnvironment.current.apiService.upsertShipAddress(
                addressId: addressId,
                name: param.name,
                phone: param.phone,
                province: param.proviceCode,
                city: param.cityCode,
                district: param.districtCode,
                detail: param.detail
                ).materialize()
            }
            .share(replay: 1)

        self.result = updateAddressResponse
            .elements()
        	.asDriver(onErrorDriveWith: .never())

        self.error = Observable.merge(
            updateAddressResponse.errors().requestErrors(),
            getAddressResponse.errors().requestErrors()
        )
    }
}
