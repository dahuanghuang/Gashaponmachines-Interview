import Argo
import Curry
import Runes

public struct UserDanmakuEnvelope {
    var picture: String?
    var msg: String
    var avatar: String?
    var avatarFrame: String?
    var type: DanmakuType?
    // 弹幕等级, 0低1高
    var level: Bool
    var machineId: String?

    // 附加属性, 展示的行号, 后台不返回该字段
    var index: Int?

    enum DanmakuType: String {
        case room
        case machine
        case all
    }
}

extension UserDanmakuEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserDanmakuEnvelope> {
        return curry(UserDanmakuEnvelope.init)
            <^> json <|? "picture"
            <*> json <| "msg"
            <*> json <|? "avatar"
            <*> json <|? "avatarFrame"
        	<*> json <|? "type"
            <*> json <| "level"
            <*> json <|? "machineId"
            <*> json <|? "index"
    }
}

extension UserDanmakuEnvelope.DanmakuType: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserDanmakuEnvelope.DanmakuType> {
        switch json {
        case let .string(type):
            switch type {
            case String(UserDanmakuEnvelope.DanmakuType.room.rawValue):
                return pure(.room)
            case String(UserDanmakuEnvelope.DanmakuType.machine.rawValue):
                return pure(.machine)
            case String(UserDanmakuEnvelope.DanmakuType.all.rawValue):
                return pure(.all)
            default:
                return .typeMismatch(expected: "UserDanmakuEnvelope.DanmakuType not match", actual: type)
            }
        default:
            return .typeMismatch(expected: "string", actual: json)
        }
    }
}
