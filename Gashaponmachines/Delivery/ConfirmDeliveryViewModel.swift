import RxCocoa
import RxSwift

struct ConfirmDeliveryViewModel {
    var viewDidLoadTrigger = PublishSubject<()>()

    var selectedAddress = PublishSubject<DeliveryAddress?>()

    var selectedCoupon = PublishSubject<Coupon?>()

    var confirmDeliverButtonTap = PublishSubject<Void>()

    var envelope: Driver<ShipInfoEnvelope>

    var products: Driver<[ShipInfoEnvelope.ShipProduct]>

    var submitResult: Driver<ConfirmShipEnvelope>

    var addressInfo: Driver<DeliveryAddress?>

    var error: Observable<ErrorEnvelope>

    init(orderIds: [String]?, mallProductId: String?, keys: [String]?, buyCount: Int?) {

        // 扭蛋发货详情
        let getInfoResponse = self.viewDidLoadTrigger.asObservable()
            .map { orderIds }
            .filterNil()
            .flatMapLatest {
                AppEnvironment.current.apiService.getShipInfo(orderIds: $0, keys: keys ?? []).materialize()
            }
            .share(replay: 1)

        // 商城发货详情
        let getMallInfoResponse = self.viewDidLoadTrigger.asObservable()
            .map { mallProductId }
            .filterNil()
            .flatMapLatest { mallProductId in
                AppEnvironment.current.apiService.getExchangeInfo(mallProductId: mallProductId).materialize()
            }
            .share(replay: 1)

        self.envelope = Observable
            .merge(
                getInfoResponse.elements(),
                getMallInfoResponse.elements()
            )
            .asDriver(onErrorDriveWith: .never())

        self.addressInfo = Driver.merge(
            envelope.map { $0.address },
            self.selectedAddress.asDriver(onErrorJustReturn: nil)
        )

        let addressId = self.addressInfo.asObservable().filterNil().map { $0.addressId }

        // 商城确认发货
        let submitMallRequestParam = Observable
        .combineLatest(
            Observable.just(mallProductId).filterNil(),
            addressId,
            selectedCoupon
        )

        let submitMallResponse = self.confirmDeliverButtonTap.asObservable()
            .withLatestFrom(submitMallRequestParam)
            .flatMapLatest { pair in
                AppEnvironment.current.apiService.exchangeMallProduct(mallProductId: pair.0, addressId: pair.1, buyCount: buyCount ?? 1, couponId: pair.2?.couponId).materialize()
            }
            .share(replay: 1)

        self.products = envelope.map { $0.products }

        // 蛋槽确认发货
        let submitEggRequestParam = Observable.combineLatest(
            Observable.just(orderIds).filterNil(),
            addressId,
            selectedCoupon
        )

        let submitEggResponse = self.confirmDeliverButtonTap.asObservable()
            .withLatestFrom(submitEggRequestParam)
            .flatMapLatest { pair in
                AppEnvironment.current.apiService.confirmShip(orderIds: pair.0, addressId: pair.1, keys: keys ?? [], couponId: pair.2?.couponId).materialize()
        	}
        	.share(replay: 1)

        self.submitResult = Observable.merge(
        		submitEggResponse.elements(),
                submitMallResponse.elements()
        	)
        	.asDriver(onErrorDriveWith: .never())

        self.error = Observable
            .merge(
                getInfoResponse.errors(),
                getMallInfoResponse.errors(),
        		submitMallResponse.errors(),
            	submitEggResponse.errors()
        	)
        	.requestErrors()
    }
}
