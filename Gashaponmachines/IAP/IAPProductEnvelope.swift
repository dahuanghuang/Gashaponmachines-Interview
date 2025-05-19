import Argo
import Curry
import Runes

public struct IAPProductEnvelope {

    var productId: String
}

extension IAPProductEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<IAPProductEnvelope> {
        return curry(IAPProductEnvelope.init)
            <^> json <| "productId"
    }
}
