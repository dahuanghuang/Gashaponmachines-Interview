import Argo
import Runes
import Curry

struct DeliveryItem {
    var title: String
    var price: Int
}

extension DeliveryItem: Hashable {
    static func == (lhs: DeliveryItem, rhs: DeliveryItem) -> Bool {
        return lhs.title == rhs.title && lhs.price == rhs.price
    }
}
