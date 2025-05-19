import RxDataSources
import RxCocoa

enum ConfirmDeliverySectionItem {
    case address(DeliveryAddress)
    case price(Int)
    case items([Product])
}

extension ConfirmDeliverySectionItem {
    var sectionIndex: Int {
        switch self {
        case .address:
            return 0
        case .price:
            return 1
        case .items:
            return 2
        }
    }
}
