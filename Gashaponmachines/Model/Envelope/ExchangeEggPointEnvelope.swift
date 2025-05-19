import Argo
import Curry
import Runes

public struct ExchangeEggPointEnvelope {

    var failProducts: [FailProduct]?

    struct FailProduct {
        var title: String
    }
}

extension ExchangeEggPointEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ExchangeEggPointEnvelope> {
        return curry(ExchangeEggPointEnvelope.init)
        	<^> json <||? "failProducts"
    }
}

extension ExchangeEggPointEnvelope.FailProduct: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ExchangeEggPointEnvelope.FailProduct> {
        return curry(ExchangeEggPointEnvelope.FailProduct.init)
            <^> json <| "title"
    }
}
