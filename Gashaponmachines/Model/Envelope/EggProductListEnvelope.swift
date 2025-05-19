import Argo
import Curry
import Runes

public struct EggProductListEnvelope {
    var typeList: [ProductType]
    var isEnd: String
    var products: [EggProduct]
    var ship: ShipInfo

    struct ProductType {
        var type: String
        var name: String
    }

    struct ShipInfo {
        var expressFee: Int
        var freeShipPrice: Int
        var expressFeeStr: String?

        var freeShipTitle: String?
        var chargeShipTitle: String?
    }
}

extension EggProductListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<EggProductListEnvelope> {
        return curry(EggProductListEnvelope.init)
            <^> json <|| "typeList"
            <*> json <| "isEnd"
        	<*> json <|| "products"
        	<*> json <| "ship"
    }
}

extension EggProductListEnvelope.ProductType: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<EggProductListEnvelope.ProductType> {
        return curry(EggProductListEnvelope.ProductType.init)
            <^> json <| "type"
            <*> json <| "name"
    }
}

extension EggProductListEnvelope.ShipInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<EggProductListEnvelope.ShipInfo> {
        return curry(EggProductListEnvelope.ShipInfo.init)
            <^> (json <| "expressFee" <|> (json <| "expressFee").map(String.toInt))
            <*> (json <| "freeShipPrice" <|> (json <| "freeShipPrice").map(String.toInt))
        	<*> json <|? "expressFeeStr"
        	<*> json <|? "freeShipTitle"
        	<*> json <|? "chargeShipTitle"
    }
}
