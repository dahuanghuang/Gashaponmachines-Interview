import Argo
import Curry
import Runes

public struct ShipListEnvelope {
    var shipList: [ShipInfo]

    struct ShipInfo {
        // [ 扭蛋发货, 蛋壳兑换 ] 其中一种
        var source: String
        // 发货 id
        var shipId: String
        // 待发货、已发货、已收货、已取消
        var statusString: String
        var products: [ShipProduct]
        // 发货订单价值
        var shipOrderWorth: String
    }

    struct ShipProduct {
        var icon: String?
        var image: String
    }
}

public struct ShipWorthEnvelope {
    // 发货订单总价值
    var eggWorth: String
    // 发货订单数量
    var shipCount: String
    // 跳转链接
    var jumpLink: String
}

extension ShipListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipListEnvelope> {
        return curry(ShipListEnvelope.init)
            <^> json <|| "shipList"
    }
}

extension ShipListEnvelope.ShipInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipListEnvelope.ShipInfo> {
        return curry(ShipListEnvelope.ShipInfo.init)
            <^> json <| "source"
            <*> json <| "shipId"
            <*> json <| "statusString"
            <*> json <|| "products"
            <*> json <| "shipOrderWorth"
    }
}

extension ShipListEnvelope.ShipProduct: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipListEnvelope.ShipProduct> {
        return curry(ShipListEnvelope.ShipProduct.init)
            <^> json <|? "icon"
            <*> json <| "image"
    }
}

extension ShipWorthEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipWorthEnvelope> {
        return curry(ShipWorthEnvelope.init)
            <^> json <| "eggWorth"
            <*> json <| "shipCount"
            <*> json <| "jumpLink"
    }
}
