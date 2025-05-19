import RxCocoa
import RxSwift

class MembershipViewModel: BaseViewModel {

    typealias ReceiptParam = (String, String)

    var memberInfo = PublishSubject<MemberInfoEnvelope>()

    var viewDidLoadTrigger = PublishSubject<Void>()

    var sendReceiptTrigger = PublishSubject<ReceiptParam>()

    var sendReceiptResult = PublishSubject<ResultEnvelope>()

    var IAPProductId = PublishSubject<IAPProductEnvelope>()

    override init() {

        super.init()

        let productIdResponse = viewDidLoadTrigger.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getIAPProduct(type: "NDMember").materialize()
            }
            .share(replay: 1)

        productIdResponse
            .elements()
            .bind(to: IAPProductId)
            .disposed(by: disposeBag)

        let sendReceiptResponse = sendReceiptTrigger
            .flatMapLatest { pair in
                AppEnvironment.current.apiService.verifyInAppPurchase(productId: pair.0, receipt: pair.1).materialize()
            }
            .share(replay: 1)

        sendReceiptResponse.elements()
            .bind(to: sendReceiptResult)
            .disposed(by: disposeBag)

        let memberInfoResponse = viewDidLoadTrigger.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getNDMemberInfo().materialize()
            }
            .share(replay: 1)

        memberInfoResponse.elements()
            .bind(to: memberInfo)
            .disposed(by: disposeBag)

        Observable.merge(
            productIdResponse.errors(),
            sendReceiptResponse.errors(),
            memberInfoResponse.errors()
            )
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
