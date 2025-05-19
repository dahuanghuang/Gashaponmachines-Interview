import Argo
import Curry
import Runes

public struct MallProductListEnvelope {
    var products: [MallProduct]
}

struct MallProduct {
    var title: String
    var image: String
    var worth: String
    var introImages: [String]?
    var productId: String?

    var isOnDiscount: String?
    var originalWorth: String?

}

extension MallProductListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallProductListEnvelope> {
        return curry(MallProductListEnvelope.init)
            <^> json <|| "products"
    }
}

extension MallProduct: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallProduct> {
        let tmp = curry(MallProduct.init)
        return tmp <^> json <| "title"
            <*> json <| "image"
            <*> json <| "worth"
        	<*> json <||? "introImages"
        	<*> json <|? "productId"
        	<*> json <|? "isOnDiscount"
        	<*> json <|? "originalWorth"
    }
}
