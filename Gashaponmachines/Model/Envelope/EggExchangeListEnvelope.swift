import Argo
import Curry
import Runes

// 获得的扭蛋集合
public struct Egg {
    var type: String
    var title: String
    var subTitle: String
    var icon: String
	// 扭蛋商品
    var products: [EggProduct]
}

extension Egg: Hashable {
    public static func == (lhs: Egg, rhs: Egg) -> Bool {
     	return lhs.type == rhs.type
            && lhs.title == rhs.title
            && lhs.subTitle == rhs.subTitle
            && lhs.icon == rhs.icon
            && lhs.products == rhs.products
    }
}

public struct EggExchangeListEnvelope {
    var eggs: [Egg]
    var noneSelectedEggTypes: [String]
}

extension EggExchangeListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<EggExchangeListEnvelope> {
        return curry(EggExchangeListEnvelope.init)
            <^> json <|| "eggs"
            <*> json <|| "noneSelectedEggTypes"
    }
}

extension Egg: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Egg> {
        return curry(Egg.init)
            <^> json <| "type"
        	<*> json <| "title"
    		<*> json <| "subTitle"
        	<*> json <| "icon"
        	<*> json <|| "products"
    }
}
