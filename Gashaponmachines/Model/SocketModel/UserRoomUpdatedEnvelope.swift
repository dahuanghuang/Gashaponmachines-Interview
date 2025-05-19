import Argo
import Curry
import Runes

public struct UserRoomUpdatedEnvelope {
    var realTimeInfo: RealTimeInfo

    struct RealTimeInfo {
        var status: Status?
        var clientCount: Int?
        var usedInfo: User?
        var roomUsers: [User]?
        var notice: String?
    }

    enum Status: String {
        case ready = "READY"
        case used = "USED"
        case stop = "STOP"
        case unknown = "UNKNOWN"
    }
}

extension UserRoomUpdatedEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserRoomUpdatedEnvelope> {
        return curry(UserRoomUpdatedEnvelope.init)
            <^> json <| "realTimeInfo"
    }
}

extension UserRoomUpdatedEnvelope.RealTimeInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserRoomUpdatedEnvelope.RealTimeInfo> {
        return curry(UserRoomUpdatedEnvelope.RealTimeInfo.init)
            <^> json <|? "status"
            <*> json <|? "clientCount"
        	<*> json <|? "usedInfo"
        	<*> json <||? "roomUsers"
        	<*> json <|? ["usedInfo", "notice"]
    }
}

extension UserRoomUpdatedEnvelope.Status: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserRoomUpdatedEnvelope.Status> {
        switch json {
        case let .string(type):
            return pure(UserRoomUpdatedEnvelope.Status(rawValue: type) ?? UserRoomUpdatedEnvelope.Status.unknown)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}
