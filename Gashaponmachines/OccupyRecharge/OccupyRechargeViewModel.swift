import RxSwift
import RxCocoa

struct OccupyRechargeViewModel {

    var options = PublishRelay<[RechargeSectionModel]>()

    var methods = BehaviorRelay<[PaymentMethod]>(value: [])

    var rechargeListEnv = PublishSubject<RechargeEnvelope>()

    var viewDidLoadTrigger = PublishSubject<Void>()

    /// 支付宝支付
    var alipayOrder: Observable<PayOrderEnvelope>

    /// 微信支付
    var wechatOrder: Observable<PayOrderEnvelope>

    /// 选择的支付方式
    var selectedPay = BehaviorSubject<PaymentMethod?>(value: nil)

    /// 选择的支付金额
    var selectedAmount = BehaviorSubject<Double>(value: 0)

    var rechargeError: Observable<ErrorEnvelope>

    /// 拉取充值列表错误
    var getRechargeListError = PublishSubject<Error>()

    private let disposeBag = DisposeBag()

    init(roomId: String, rechargeSignal: Signal<Void>) {

        let rechargeListResponse = viewDidLoadTrigger.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getOccupyRechargeList(roomId: roomId).materialize()
        	}
        	.share(replay: 1)

        rechargeListResponse.elements()
            .map { $0.paymentMethods }
            .bind(to: methods)
            .disposed(by: disposeBag)

        rechargeListResponse.elements()
        	.bind(to: rechargeListEnv)
        	.disposed(by: disposeBag)

        let payParam =
            Observable.combineLatest(
            	self.selectedAmount.asObservable(),
            	self.selectedPay.asObservable()
            )
            .map { (amount: $0.0, method: $0.1 )}

        let rechargeObservable =
            rechargeSignal.asObservable()
            	.withLatestFrom(payParam)

        let wechatOrderResponse =
            rechargeObservable
                .filter { $0.method != nil }
                .filter { $0.method!.rechargeFrom == PaymentType.wechat }
                .flatMapLatest { pair in
                    AppEnvironment.current.apiService.signPayOrder(amount: pair.amount, payMethod: pair.method!.rechargeFrom.rawValue, payFrom: .occupyRecharge, paymentPlanId: nil).materialize()
        		}
        		.share(replay: 1)

        self.wechatOrder =
            wechatOrderResponse
                .elements()

        // 获取支付签名
        let alipayOrderResponse =
            rechargeObservable
                .filter { $0.method != nil }
                .filter { $0.method!.rechargeFrom == PaymentType.alipay }
                .flatMapLatest { pair in
                    AppEnvironment.current.apiService.signPayOrder(amount: pair.amount, payMethod: pair.method!.rechargeFrom.rawValue, payFrom: .occupyRecharge, paymentPlanId: nil).materialize()
                }
                .share(replay: 1)

        self.alipayOrder =
            alipayOrderResponse
                .elements()

        self.rechargeError =
            Observable.merge(
            	alipayOrderResponse.errors(),
            	wechatOrderResponse.errors()
            )
            .requestErrors()

        rechargeListResponse.errors()
            .bind(to: getRechargeListError)
            .disposed(by: disposeBag)
    }
}
