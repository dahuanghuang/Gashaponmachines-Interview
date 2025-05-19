import Argo
import Curry
import Runes

public struct MallCollectionProductListEnvelope {
    var title: String?
    var products: [MallProduct]
}

extension MallCollectionProductListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallCollectionProductListEnvelope> {
        return curry(MallCollectionProductListEnvelope.init)
            <^> json <|? "title"
            <*> json <|| "products"
    }
}
