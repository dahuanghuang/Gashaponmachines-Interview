import Argo
import Curry
import Runes

public struct ShipInfoEnvelope {
    // 邮费: 80元气
    var expressFee: String
    // 邮费价值: 80
    var expressFeeAmount: String?
    // 发货商品
    var products: [ShipProduct]
    // 地址
    var address: DeliveryAddress?
    // 可使用优惠券
    var availCoupons: [Coupon]?
    // 全部优惠券
    var allCoupons: [Coupon]?
    // 邮费提示文字
    var freeShipTitle: String?
    var unableAffordTips: Tip?
    // 是否用元气支付运费，1 表示是，0 表示不是
    var isAffordShipByBalance: String?

    struct ShipProduct {
        var title: String?
        var image: String?
        var icon: String?
        var count: String
    }

    struct Tip {
        var title: String
        var subTitle: String
        var button1Title: String?
        var button1Jump: String?
        var button2Title: String?
        var button2Jump: String?
    }
}

extension ShipInfoEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipInfoEnvelope> {
        let t = curry(ShipInfoEnvelope.init)
        return t <^> json <| "expressFee"
            <*> json <|? "expressFeeAmount"
            <*> json <|| "products"
            <*> json <|? "address"
            <*> json <||? "availCoupons"
            <*> json <||? "allCoupons"
        	<*> json <|? "freeShipTitle"
        	<*> json <|? "unableAffordTips"
        	<*> json <|? "isAffordShipByBalance"
    }
}

extension ShipInfoEnvelope.ShipProduct: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipInfoEnvelope.ShipProduct> {
        let t = curry(ShipInfoEnvelope.ShipProduct.init)
        return t <^> json <|? "title"
            <*> json <|? "image"
            <*> json <|? "icon"
            <*> json <| "count"
    }
}

extension ShipInfoEnvelope.Tip: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipInfoEnvelope.Tip> {
        let t = curry(ShipInfoEnvelope.Tip.init)
        return t
            <^> json <| "title"
            <*> json <| "subTitle"
            <*> json <|? "button1Title"
            <*> json <|? "button1Jump"
            <*> json <|? "button2Title"
            <*> json <|? "button2Jump"
    }
}
