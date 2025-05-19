import Argo
import Curry
import Runes
import RxDataSources

public struct AwardDetailEnvelope {
    var products: [Product]?
}

extension AwardDetailEnvelope: SectionModelType {
    public var items: [Product] {
        return self.products ?? []
    }

    public init(original: AwardDetailEnvelope, items: [Product]) {
        self = original
    }

    public typealias Item = Product
}

extension AwardDetailEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<AwardDetailEnvelope> {
        return curry(AwardDetailEnvelope.init)
            <^> json <||? "products"
    }
}
