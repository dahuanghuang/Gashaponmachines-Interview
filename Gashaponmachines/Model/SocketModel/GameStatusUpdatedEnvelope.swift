import Argo
import Curry
import Runes

public struct GameStatusUpdatedEnvelope {
    // 事件Id，0-9A-Z组成的6位字符串，用户操作引后续的响应eventID会与用户发送过来的一致
    var eventId: String
    // 事件code，正常为200，其他数值为异常
    var code: String
    // 游戏状态
    var gameStatus: Game.State?
    // 扭蛋订单ID
    var orderId: String?
    // 状态有效事件，单位为毫秒
    var ttl: String?
    // 用户余额，用户抢占机台成功的通知中会有这个字段
    var balance: String?
    // 提示标题，WARNING及ERROR中会有这个内容
    var title: String?
    // 提示文案，WARNING及ERROR中会有这个内容
    var msg: String?
    // 暴击倍数, 用于处理暴击状态的
    var critMultiple: Int?
    // 游戏结果信息
    var successInfo: GameSuccessInfo?
    // 暴击信息
    var powerInfo: PowerInfo?
}

struct GameSuccessInfo {
    var icon: String?
//    var danmu: String?
    var type: BallColorType?
    var image: String?
    var title: String?
    var isKOI: Bool?
    var buttons: [GameStatusButtonInfo]?
    /// 暴击个数
    var critMultiple: Int?
}

public struct GameStatusButtonInfo {
    var title: String
    var type: String
}

/// 扭蛋的颜色
///
enum BallColorType: String {
    case white  = "1"
    case yellow = "2"
    case green  = "3"
    case cyan   = "4"
    case blue   = "5"
    case purple = "6"
    case red    = "7"
    case pink   = "8"
    case black  = "9"

    var ballBundlePath: String {
        switch self {
        case .white:
            return "lucky_anim_white"
        case .yellow:
            return "lucky_anim_yellow"
        case .green:
            return "lucky_anim_green"
        case .cyan:
            return "lucky_anim_cyan"
        case .blue:
            return "lucky_anim_blue"
        case .purple:
            return "lucky_anim_purple"
        case .red:
            return "lucky_anim_red"
        case .pink:
            return "lucky_anim_pink"
        case .black:
            return "lucky_anim_black"
        }
    }

    var ballBundle: Bundle {
        let bundlePath = Bundle.main.path(forResource: self.ballBundlePath, ofType: "bundle")!
        return Bundle(path: bundlePath)!
    }
    
    var bgBundlePath: String? {
        switch self {
        case .green:
            return "game_bg_green"
        case .cyan:
            return "game_bg_cyan"
        case .blue:
            return "game_bg_blue"
        case .purple:
            return "game_bg_purple"
        case .red:
            return "game_bg_red"
        case .pink:
            return "game_bg_pink"
        case .black:
            return "game_bg_black"
        case .yellow, .white:
            return nil
        }
    }

    var bgBundle: Bundle? {
        if let path = self.bgBundlePath {
            let bundlePath = Bundle.main.path(forResource: path, ofType: "bundle")!
            return Bundle(path: bundlePath)
        }else {
            return nil
        }
    }
}

enum GameStatusButtonType: String {
    // 重新开始
    case restart = "G_RST"
    // 不玩
    case cancel = "G_CXL"
    // 霸机充值
    case recharge = "G_RCHG"
}

extension GameStatusButtonInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GameStatusButtonInfo> {
        return curry(GameStatusButtonInfo.init)
            <^> json <| "title"
            <*> json <| "type"
    }
}

extension BallColorType: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BallColorType> {
        switch json {
        case let .string(type):
            return pure(BallColorType(rawValue: type) ?? BallColorType.white)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

extension GameStatusUpdatedEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GameStatusUpdatedEnvelope> {
        return curry(GameStatusUpdatedEnvelope.init)
            <^> json <| "eventId"
            <*> (json <| "code" <|> (json <| "code").map(Int.toString))
            <*> json <|? "gameStatus"
            <*> json <|? "orderId"
            <*> (json <|? "ttl" <|> (json <| "ttl").map(Int.toString) )
            <*> json <|? "balance"
            <*> json <|? "title"
            <*> json <|? "msg"
            <*> (json <|? "critMultiple" <|> (json <| "critMultiple").map(String.toInt))
            <*> json <|? "successInfo"
            <*> json <|? "powerInfo"
    }
}

extension GameSuccessInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GameSuccessInfo> {
        return curry(GameSuccessInfo.init)
            <^> json <|? "icon"
//            <*> json <|? "danmaku"
            <*> json <|? "type"
            <*> json <|? "image"
            <*> json <|? "title"
            <*> ((json <|? "isKOI") <|> (json <|? "isKOI").map(String.toBool))
            <*> json <||? "button"
            <*> ((json <|? "critMultiple") <|> (json <|? "critMultiple").map(String.toInt))
    }
}
