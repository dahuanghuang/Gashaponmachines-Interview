import Argo
import Curry
import Runes

public struct MallProductDetailEnvelope {
    var product: MallProduct
    /// 当前蛋壳余额是否可以兑换该商品
    var canExchange: String
    /// 蛋壳余额
    var balance: String?
    /// 最多能购买数
    var canExchangeLimited: String?
    /// 超过最多兑换次数时提示的文案
    var reasonForLimitation: String?
    var defaultAddress: DeliveryAddress?
    /// 提醒弹窗标题
    var notification1: String?
    /// 提醒弹窗子标题
    var notification2: String?
    
}

extension MallProductDetailEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallProductDetailEnvelope> {
        return curry(MallProductDetailEnvelope.init)
            <^> json <| "product"
        	<*> json <| "canExchange"
            <*> json <|? "balance"
            <*> json <|? "canExchangeLimited"
            <*> json <|? "reasonForLimitation"
        	<*> json <|? "defaultAddress"
            <*> json <|? "notification1"
            <*> json <|? "notification2"
    }
}
