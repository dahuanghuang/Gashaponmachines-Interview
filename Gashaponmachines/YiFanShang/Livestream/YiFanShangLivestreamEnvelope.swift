import Argo
import Runes
import Curry

enum YiFanShangStatus: String {
    // 销售中
    case onSale = "on_sale"
    // 等待机器中
    case waitMachine = "wait_machine"
    // 开赏中
    case livePlaying = "live_playing"
    // 直播结束录像生成中
    case liveFinish = "live_finish"
    // 录像生成完成
    case videoFinish = "video_finish"
    // 故障中
    case error = "in_error"

    var iconColor: UIColor {
        switch self {
        case .livePlaying: return UIColor.UIColorFromRGB(0x00ff00)
        case .onSale, .waitMachine: return UIColor.UIColorFromRGB(0x00ff00, alpha: 0.1)
        case .error: return UIColor.UIColorFromRGB(0xff0000)
        case .liveFinish, .videoFinish: return UIColor.UIColorFromRGB(0xececec)
        }
    }
}

// enum YiFanShangAwardType: String {
//    case empty = "0"
//    case A = "101"
//    case B = "102"
//    case C = "103"
//    case D = "104"
//    case E = "105"
//    case F = "106"
//
//    var image: UIImage? {
//        return UIImage(named: "yfs_reward_\(self.rawValue)")
//    }
//
//    var outlineImage: UIImage? {
//        return UIImage(named: "yfs_reward_\(self.rawValue)_outline")
//    }
// }

// extension String {
//    static func toYiFanShangAwardType(_ type: String?) -> YiFanShangAwardType {
//        return YiFanShangAwardType(rawValue: type ?? "0") ?? .empty
//    }
// }

// extension Int {
//    static func toYiFanShangAwardType(_ type: Int?) -> YiFanShangAwardType {
//        if let type = type {
//            return YiFanShangAwardType(rawValue: String(type)) ?? .empty
//        }
//        return .empty
//    }
// }

extension YiFanShangStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<YiFanShangStatus> {
        switch json {
        case let .string(status):
            return pure(YiFanShangStatus(rawValue: status) ?? .waitMachine)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

/// 一番赏页面长链接返回的数据
struct YiFanShangLivestreamInfo {

    /// 左上角的状态信息
    var statusInfo: StatusInfo?

    /// 赏信息
    var eggInfo: [LiveEggInfo]?

    /// 当前房间人数总数
    var clientCount: String?

    /// 当前房间部分用户，不超过4个
    var roomUsers: [User]?

    /// 运行时间提示文案
    var launchNotice: String?

    /// 运行时间时间戳
    var launchTime: String?

    /// 直播视频地址
    var liveAddress: String?

    /// 录像地址
    var videoAddress: String?

    /// 期号
    var serial: String?

    /// 底部区域提示信息
    var centerNotice: CenterNotice?

    /// 奖励信息
    var awardInfo: AwardInfo?

    struct StatusInfo {
        /// 状态
        var status: YiFanShangStatus?

        /// 提示文案
        var notice: String?

        /// 可选，倒计时时间，等待机器中至开赏中转换倒计时
        var ttl: String?
    }

    struct CenterNotice {

        /// 用户头像
        var avatar: String?

        /// 用户昵称
        var nickname: String?

        /// 赏的类型
//        var awardType: YiFanShangAwardType?
        var awardType: String?

        /// 提示内容，等待中时，有此字段
        var notice: String?

        /// 赏的序号
        var number: String?

        /// 当前的房间ID
        var gameId: String?
    }

    /// 详情赏
    struct LiveEggInfo {
        /// 蛋图片
        var eggIcon: String?
        /// 赏标题
        var eggTitle: String?
        /// 赏类型
        var eggType: String?
        /// 开赏图片(描边)
        var eggAwardBigIcon: String?
        /// 开赏图片(非描边)
        var eggAwardSmallIcon: String?
        /// 当前蛋个数
        var eggContent: String?
        /// 所有蛋总个数
        var totalEggCount: String?
    }

    struct AwardInfo {
        /// 奖品类型
//        var awardType: YiFanShangAwardType?
        /// 用户奖励ID
        var onePieceOrderId: String?
        /// 第几回合
        var number: String?
        // 奖品类型
        var awardType: String?

        var userId: String?

        var uid: String?
    }
    /// 魔法阵的记录
    var magicRecord: [YiFanShangLiveStreamRecord]?
    /// 元气赏的记录
    var yfsRecord: [YiFanShangLiveStreamRecord]?
}

struct YiFanShangLiveStreamRecord: Equatable {
    var userId: String?
    var nickname: String?
    var avatar: String?
    var avatarFrame: String?
    var number: String?
    var awardType: String?
    var award: String?
    var onePieceOrderId: String?
    var imageUrl: String?
    var isMagic: Bool
}

extension YiFanShangLivestreamInfo.LiveEggInfo: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<YiFanShangLivestreamInfo.LiveEggInfo> {
        return curry(YiFanShangLivestreamInfo.LiveEggInfo.init)
            <^> json <| "eggIcon"
            <*> json <| "eggTitle"
            <*> (json <| "eggType" <|> (json <|? "eggType").map(Int.toString))
            <*> json <| "eggAwardBigIcon"
            <*> json <| "eggAwardSmallIcon"
            <*> (json <|? "eggContent" <|> (json <|? "eggContent").map(Int.toString))
            <*> (json <|? "totalEggCount" <|> (json <|? "totalEggCount").map(Int.toString))
    }
}

extension YiFanShangLiveStreamRecord: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<YiFanShangLiveStreamRecord> {
        let a = curry(YiFanShangLiveStreamRecord.init)
            <^> json <|? "userId"
            <*> json <|? "nickname"
            <*> json <|? "avatar"
            <*> json <|? "avatarFrame"
            <*> (json <|? "number" <|> (json <|? "number").map(Int.toString))
        let b = a
            <*> (json <|? "awardType" <|> (json <|? "awardType").map(Int.toString))
            <*> json <|? "award"
            <*> json <|? "onePieceOrderId"
            <*> json <|? "imageUrl"
            <*> (json <| "isMagic" <|> (json <| "isMagic").map(String.toBool))
        return b
    }
}

extension YiFanShangLivestreamInfo.CenterNotice: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<YiFanShangLivestreamInfo.CenterNotice> {
        return curry(YiFanShangLivestreamInfo.CenterNotice.init)
            <^> json <|? "avatar"
            <*> json <|? "nickname"
            <*> (json <|? "awardType" <|> (json <|? "awardType").map(Int.toString))
            <*> json <|? "notice"
            <*> (json <|? "number" <|> (json <|? "number").map(Int.toString))
            <*> (json <|? "gameId" <|> (json <|? "gameId").map(Int.toString))
    }
}

extension YiFanShangLivestreamInfo.AwardInfo: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<YiFanShangLivestreamInfo.AwardInfo> {
        return curry(YiFanShangLivestreamInfo.AwardInfo.init)
//            <^> ((json <|? "awardType").map(String.toYiFanShangAwardType) <|> (json <|? "awardType").map(Int.toYiFanShangAwardType))
            <^> json <|? "onePieceOrderId"
            <*> (json <|? "number" <|> (json <|? "number").map(Int.toString))
            <*> (json <|? "awardType" <|> (json <|? "awardType").map(Int.toString))
            <*> (json <|? "userId" <|> (json <|? "userId").map(Int.toString))
            <*> (json <|? "uid" <|> (json <|? "uid").map(Int.toString))
    }
}

struct YiFanShangLivestreamListenEnvelope {

    var onePieceInfo: YiFanShangLivestreamInfo?
}

extension YiFanShangLivestreamListenEnvelope: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<YiFanShangLivestreamListenEnvelope> {
        return curry(YiFanShangLivestreamListenEnvelope.init)
                <^> json <|? "onePieceInfo"
    }
}

struct YiFanShangLivestreamEnvelope {

    var data: YiFanShangLivestreamInfo?

    // 状态码
    var code: Int?
    var msg: String?

}

extension YiFanShangLivestreamEnvelope: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<YiFanShangLivestreamEnvelope> {
        return curry(YiFanShangLivestreamEnvelope.init)
                <^> json <|? "data"
                <*> json <|? "code"
                <*> json <|? "msg"
    }
}

extension YiFanShangLivestreamInfo: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<YiFanShangLivestreamInfo> {
        return curry(YiFanShangLivestreamInfo.init)
            <^> json <|? "statusInfo"
            <*> json <||? "eggInfo"
            <*> (json <|? "clientCount" <|> (json <|? "clientCount").map(Int.toString))
            <*> json <||? "roomUsers"
            <*> json <|? "launchNotice"
            <*> (json <|? "launchTime" <|> (json <|? "launchTime").map(Int.toString))
            <*> json <|? "liveAddress"
            <*> json <|? "videoAddress"
            <*> json <|? "serial"
            <*> json <|? "centerNotice"
            <*> json <|? "awardInfo"
            <*> json <||? ["recordList", "magic"]
            <*> json <||? ["recordList", "total"]
    }
}

extension YiFanShangLivestreamInfo.StatusInfo: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<YiFanShangLivestreamInfo.StatusInfo> {
        return curry(YiFanShangLivestreamInfo.StatusInfo.init)
            <^> json <|? "status"
            <*> json <|? "notice"
            <*> (json <|? "ttl" <|> (json <|? "ttl").map(Int.toString))
    }
}
