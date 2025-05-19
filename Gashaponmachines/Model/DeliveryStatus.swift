import Argo
import Runes
import Curry

enum DeliveryStatus: Int, CaseIterable {
    case toBeDelivered = 10 // 待发货
    case delivered = 20     // 已发货
    case received = 25      // 已完成
    case canceled = 30      // 已取消

    var description: String {
        switch self {
        case .toBeDelivered:
            return "待发货"
        case .delivered:
            return "已发货"
        case .received:
            return "已完成"
        case .canceled:
            return "已取消"
        }

    }

    var image: UIImage? {
        switch self {
        case .toBeDelivered:
            return UIImage(named: "delivery_detail")
        case .delivered:
            return UIImage(named: "delivery_detail_delivered")
        case .received:
            return UIImage(named: "delivery_detail_received")
        case .canceled:
            return UIImage(named: "delivery_detail_cancel")
        }
    }
}

extension DeliveryStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<DeliveryStatus> {
        switch json {
        case let .string(status):
            switch status {
            case String(DeliveryStatus.toBeDelivered.rawValue):
                return pure(.toBeDelivered)
            case String(DeliveryStatus.delivered.rawValue):
                return pure(.delivered)
            case String(DeliveryStatus.received.rawValue):
                return pure(.received)
            case String(DeliveryStatus.canceled.rawValue):
                return pure(.canceled)
            default:
                return .typeMismatch(expected: "DeliveryStatus not match", actual: status)
            }
        default:
            return .typeMismatch(expected: "Number", actual: json)
        }
    }
}
