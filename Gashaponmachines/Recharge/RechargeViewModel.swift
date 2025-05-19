import RxSwift
import RxCocoa
import RxSwiftExt
//import Result
import Argo

public enum PaymentType: String, Argo.Decodable {
    case wechat
    case alipay
    case webpay
    case unionPayApp
}

struct RechargeViewModel {

    var viewWillAppearTrigger = PublishSubject<Void>()

    /// 订单号码
    var alipayOutTradeNumber = PublishSubject<String>()

    /// 选择的支付方式
    var selectedPay = BehaviorSubject<PaymentMethod?>(value: nil)

    /// 选择的支付金额
    var selectedAmount = BehaviorSubject<Double>(value: 0)

    /// 充值方案ID
    var paymentPlanId = BehaviorSubject<String?>(value: nil)

    /// 查询微信支付回调结果
    var queryWechatPayResultTrigger = PublishSubject<Void>()

    /// 支付按钮是否可点击状态
    var isRechargeButtonEnable: Driver<Bool>

    /// 拉取支付页面信息
    var envelope: Observable<PaymentPlanListEnvelope>

    /// 支付宝支付
    var alipayOrder: Observable<PayOrderEnvelope>

    /// 微信支付
    var wechatOrder: Observable<PayOrderEnvelope>

    /// 向服务器查询支付状态
    var queryedResult: Driver<QueryPayOrderEnvelope>

    var error: Observable<ErrorEnvelope>

    /// 查询订单请求出错
    var queryOrderError: Observable<ErrorEnvelope>

    private let disposeBag = DisposeBag()

    /// 尝试查询订单状态的次数
    var retryQueryCount = BehaviorRelay<Int>(value: 0)

    init(rechargeButtonTap: Signal<Void>) {

        rechargeButtonTap.asObservable()
            .mapTo(0)
        	.bind(to: retryQueryCount)
        	.disposed(by: disposeBag)

        // 支付列表数据
        let rechargeListResponse =
            self.viewWillAppearTrigger.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getPaymentPlanList().materialize()
            }
            .share(replay: 1)

        self.envelope = rechargeListResponse
                .elements()

        let payParam = Observable.combineLatest(
            self.paymentPlanId.asObservable(),
            self.selectedAmount.asObservable(),
            self.selectedPay.asObservable()
        )
        .map { (paymentId: $0.0, amount: $0.1, method: $0.2)}

        self.isRechargeButtonEnable =
            payParam
            .map { $0.paymentId != nil && $0.amount > 0 && $0.method != nil }
            .asDriver(onErrorJustReturn: false)

        let rechargeObservable = rechargeButtonTap.asObservable()
            .withLatestFrom(payParam)

        // 微信
        let wechatOrderResponse =
            rechargeObservable
            .filter { $0.paymentId != nil }
            .filter { $0.method != nil }
            .filter { $0.method!.rechargeFrom == PaymentType.wechat }
            .flatMapLatest { pair in
                AppEnvironment.current.apiService.signPayOrder(amount: pair.amount, payMethod: pair.method!.rechargeFrom.rawValue, payFrom: .normal, paymentPlanId: "").materialize()
        	}
        	.share(replay: 1)

        self.wechatOrder =
            wechatOrderResponse
            .elements()

        // 支付宝
        let alipayOrderResponse =
            rechargeObservable
            .filter { $0.paymentId != nil }
            .filter { $0.method != nil }
            .filter { $0.method!.rechargeFrom == PaymentType.alipay }
            .flatMapLatest { pair in
                AppEnvironment.current.apiService.signPayOrder(amount: pair.amount, payMethod: pair.method!.rechargeFrom.rawValue, payFrom: .normal, paymentPlanId: "").materialize()
        	}
            .share(replay: 1)

        self.alipayOrder = alipayOrderResponse
            .elements()

        let queryResultResponse = Observable.merge(
            	self.alipayOutTradeNumber,
            	self.queryWechatPayResultTrigger.withLatestFrom(self.wechatOrder.map { $0.outTradeNum })
            )
            .flatMapLatest { tradeNum in
                AppEnvironment.current.apiService.queryPayOrder(outTradeNumber: tradeNum).materialize()
        	}
        	.share(replay: 1)

        self.queryOrderError = queryResultResponse.errors().requestErrors()

        self.queryedResult = queryResultResponse
        	.elements()
        	.asDriver(onErrorDriveWith: .never())

        self.error = Observable.merge(
        	rechargeListResponse.errors(),
            alipayOrderResponse.errors(),
            wechatOrderResponse.errors()
        )
        .requestErrors()
    }
}

import Argo
import Curry
import Runes

public struct PaymentPlanListEnvelope {
    var balance: String
    var paymentPlanList: [PaymentPlan]
}

public struct PaymentPlan {
    // 充值方案ID
    var paymentPlanId: String
    // 充值方案标题("共10050元气")
    var title: String
    // 充值方案副标题（"10000元气+50元气")
    var description: String
    // 充值方案图标
    var planIcon: String
    // 充值金额
    var amount: String
    // 方案提示("支付宝充值送50！")
    var tipInfo: PaymentTipInfo?
    // 是否选中
    var selected: Bool
    // 充值渠道
    var paymentMethods: [PaymentMethod]
}

public struct PaymentTipInfo {
    // 方案文字 "支付宝充值送50！"
    var text: String
    // 方案背景颜色
    var color: String
}

extension PaymentPlanListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PaymentPlanListEnvelope> {
        return curry(PaymentPlanListEnvelope.init)
            <^> json <| "balance"
            <*> json <|| "paymentPlanList"
    }
}

extension PaymentPlan: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PaymentPlan> {
        return curry(PaymentPlan.init)
            <^> json <| "paymentPlanId"
            <*> json <| "title"
            <*> json <| "description"
            <*> json <| "planIcon"
            <*> json <| "amount"
            <*> json <|? "tipInfo"
            <*> (json <| "selected" <|> (json <| "selected").map(String.toBool))
            <*> json <|| "paymentMethods"
    }
}

extension PaymentTipInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PaymentTipInfo> {
        return curry(PaymentTipInfo.init)
            <^> json <| "text"
            <*> json <| "color"
    }
}
