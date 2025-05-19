import RxSwift
import RxCocoa

struct MallDetailViewModel {
    var viewDidLoadTrigger = PublishSubject<Void>()
    var detail: Observable<MallProductDetailEnvelope>

//    var canExchange: Driver<Bool>
    // 兑换按钮
//    var exchangeButtonTap = PublishSubject<Void>()

    // 提交结果
//    var exchangeResult: Observable<MallProductExchangeEnvelope>

    var error: Observable<ErrorEnvelope>

    init(mallProductId: String) {

        let detailRequest = self.viewDidLoadTrigger
            .asObservable()
            .flatMapLatest { _ in
            	AppEnvironment.current.apiService.getMallProductDetail(mallProductId: mallProductId).materialize()
        	}
            .share(replay: 1)

        self.detail = detailRequest
        	.elements()

//        self.canExchange = exchangeButtonTap.asObservable()
//            .withLatestFrom(self.detail)
//            .map { $0.canExchange == "1" }
//            .asDriver(onErrorDriveWith: .never())

//        let exchangeRequest = self.exchangeButton
//            .asObservable()
//            .withLatestFrom(address.filterNil().map { $0.addressId })
//            .flatMapLatest { addressId in
//                AppEnvironment.current.apiService.exchangeMallProduct(mallProductId: mallProductId, addressId: addressId).materialize()
//            }
//            .share(replay: 1)

//        self.exchangeResult = exchangeRequest
//            .elements()

        self.error = detailRequest
            .errors()
        	.requestErrors()
    }
}
