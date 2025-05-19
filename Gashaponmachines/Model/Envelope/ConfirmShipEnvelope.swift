import Argo
import Curry
import Runes

public struct ConfirmShipEnvelope {
    var code: String
    var msg: String
    var failureProducts: [FailProduct]?
    var shipNumber: String?
    var shipId: String?

    struct FailProduct {
        var title: String
    }
}

extension ConfirmShipEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ConfirmShipEnvelope> {
        let t = curry(ConfirmShipEnvelope.init)
        return t
            <^> json <| "code"
            <*> json <| "msg"
            <*> json <||? ["data", "failureProducts"]
            <*> json <|? ["data", "shipNumber"]
        	<*> json <|? ["data", "shipId"]
    }
}

extension ConfirmShipEnvelope.FailProduct: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ConfirmShipEnvelope.FailProduct> {
        let t = curry(ConfirmShipEnvelope.FailProduct.init)
        return t <^> json <| "title"
    }
}
