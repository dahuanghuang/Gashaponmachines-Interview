import Argo
import Curry
import Runes

public struct ShipDetailEnvelope {
    var address: ShipDetailAddress
    var products: [ShipDetailProduct]
    var shipNumber: String
    var confirmDate: String
    var shipmentTitle: String
    var shipmentSubtitle: String
    var expressCompany: String?
    var expressNumber: String?
    var shipDate: String?
    var status: DeliveryStatus
    var cyberInfo: [CyberInfo]?
    var usage: String?

    struct CyberInfo {
        /// 卡号
        var cardNo: String?
        var cardNoText: String?
        /// 卡密
        var cardPw: String?
        var cardPwText: String?
        /// 兑换码
        var cardCode: String?
        var cardCodeText: String?
    }

    struct ShipDetailAddress {
        var name: String
        var phone: String
        var address: String
    }

    struct ShipDetailProduct {
        var title: String
        var image: String
        var count: String
        var luckyTime: String?
    }
}

extension ShipDetailEnvelope.ShipDetailProduct: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipDetailEnvelope.ShipDetailProduct> {
        let t = curry(ShipDetailEnvelope.ShipDetailProduct.init)
        return t <^> json <| "title"
            <*> json <| "image"
            <*> json <| "count"
        	<*> json <|? "luckyTime"
    }
}

extension ShipDetailEnvelope.ShipDetailAddress: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipDetailEnvelope.ShipDetailAddress> {
        let t = curry(ShipDetailEnvelope.ShipDetailAddress.init)
        return t <^> json <| "name"
        	<*> json <| "phone"
        	<*> json <| "address"
    }
}

extension ShipDetailEnvelope.CyberInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipDetailEnvelope.CyberInfo> {
        return curry(ShipDetailEnvelope.CyberInfo.init)
            <^> json <|? "cardNo"
            <*> json <|? "cardNoText"
            <*> json <|? "cardPw"
        	<*> json <|? "cardPwText"
        	<*> json <|? "cardCode"
            <*> json <|? "cardCodeText"
    }
}

extension ShipDetailEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipDetailEnvelope> {
        let t = curry(ShipDetailEnvelope.init)
        let t1 = t <^> json <| "address"
                   <*> json <|| "products"
        		   <*> json <| "shipNumber"
        let t2 = t1  <*> json <| "confirmDate"
                   <*> json <| ["shipmentNotice", "title"]
            	   <*> json <| ["shipmentNotice", "subTitle"]
                   <*> json <|? ["shipmentNotice", "expressCompany"]
                   <*> json <|? ["shipmentNotice", "expressNumber"]
            return t2 <*> json <|? "shipDate"
                   <*> json <| "status"
                   <*> json <||? "cyberInfo"
        		   <*> json <|? "usage"
    }
}
