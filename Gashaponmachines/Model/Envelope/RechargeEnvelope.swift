import Argo
import Curry
import Runes

public struct RechargeEnvelope {
    var balance: String?
    var options: [PaymentOption]
    var paymentMethods: [PaymentMethod]
}

// 充值选项
struct PaymentOption {
    var icon: String
    // 充值数额说明
    var title: String
    // 充值数额: 单位（元）
    var amount: String
    // 是否默认选中，1 为选中，0 未选中
    var selected: Bool
}

// 充值渠道
public struct PaymentMethod {
    // 支付渠道名称
    var title: String
    // 充值说明，如充100送50
    var subTitle: String
    // 微信 支付宝
    var rechargeFrom: PaymentType
    // 充值渠道图标
    var icon: String
    // 是否默认选中，1 为选中，0 未选中
    var selected: Bool
}

public enum PayFrom: Int {
    // 普通充值
    case normal = 1
    // 霸机充值
    case occupyRecharge = 2
}

extension RechargeEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<RechargeEnvelope> {
        return curry(RechargeEnvelope.init)
		<^> json <|? "balance"
        <*> json <|| "choices"
        <*> json <|| "paymentMethods"
    }
}

extension PaymentOption: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PaymentOption> {
        return curry(PaymentOption.init)
            <^> json <| "icon"
            <*> json <| "title"
            <*> json <| "amount"
            <*> (json <| "selected" <|> (json <| "selected").map(String.toBool))
    }
}

extension PaymentMethod: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PaymentMethod> {
        let tmp = curry(PaymentMethod.init)
        let tmp1 = tmp
            <^> json <| "title"
            <*> json <| "subTitle"
            <*> json <| "rechargeFrom"
        return tmp1
            <*> json <| "icon"
        	<*> (json <| "selected" <|> (json <| "selected").map(String.toBool))
    }
}
