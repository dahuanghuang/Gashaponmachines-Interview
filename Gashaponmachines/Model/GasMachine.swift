import Argo
import Runes
import Curry

public struct GasMachine {
    var title: String
    var image: String
    var price: String
    var physicId: String
    var status: String
    var type: MachineColorType
    var owner: MachineOwner?
}

enum MachineColorType: String {
    case white = "1"
    case yellow = "2"
    case green = "3"
    case red = "4"
    case black = "5"

    var icon: UIImage? {
        switch self {
        case .white:  return UIImage(named: "index_mac_white")
        case .yellow: return UIImage(named: "index_mac_yellow")
        case .green:  return UIImage(named: "index_mac_green")
        case .red:    return UIImage(named: "index_mac_red")
        case .black:  return UIImage(named: "index_mac_black")
        }
    }

    var criticalIcon: UIImage? {
        switch self {
        case .white:  return UIImage(named: "home_machine_1")
        case .yellow: return UIImage(named: "home_machine_2")
        case .green:  return UIImage(named: "home_machine_3")
        case .red:    return UIImage(named: "home_machine_4")
        case .black:  return UIImage(named: "home_machine_5")
        }
    }

    var loadingImage: UIImage? {
        switch self {
        case .white: return UIImage(named: "game_loading_1")
        case .yellow: return UIImage(named: "game_loading_2")
        case .green: return UIImage(named: "game_loading_3")
        case .red:   return UIImage(named: "game_loading_4")
        case .black: return UIImage(named: "game_loading_5")
        }
    }
}

public struct MachineOwner {
    var nickname: String
    var avatar: String
}

extension MachineOwner: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MachineOwner> {
        let t = curry(MachineOwner.init)
        return t
            <^> json <| "nickname"
        	<*> json <| "avatar"
    }
}

extension GasMachine: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GasMachine> {
        let tmp = curry(GasMachine.init)
        let t1 = tmp <^> json <| "title"
        <*> json <| "image"
        <*> json <| "price"
        return t1
        <*> json <| "physicId"
        <*> json <| "status"
        <*> json <| "type"
        <*> json <|? "owner"
    }
}

extension MachineColorType: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MachineColorType> {
        switch json {
        case let .string(type): return pure(MachineColorType(rawValue: type) ?? .white)
        case let .number(type): return pure(MachineColorType(rawValue: type.stringValue) ?? .white)
        default: return .typeMismatch(expected: "Wrong MachineColorType type", actual: json)
        }
    }
}
