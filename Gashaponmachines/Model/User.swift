import Argo
import Curry
import Runes

public struct User: Codable {

    let uid: String?

    let _id: String?

    let username: String?

    let nickname: String?

    let avatar: String?
    /// 头像框
    let avatarFrame: String?
}

extension User: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<User> {
        let t = curry(User.init)
        return t
            <^> json <|? "uid"
            <*> json <|? "_id"
            <*> json <|? "username"
            <*> json <|? "nickname"
        	<*> json <|? "avatar"
            <*> json <|? "avatarFrame"
    }
}

public struct UserInfoEnvelope {
    var userInfo: UserInfo
    var banner: [UserBanner]?
    var services: [UserService]?
}

/// Banner
public struct UserBanner {
    /// 跳转链接
    var action: String
    /// 立即签到图片
    var icon: String?
    /// 图片
    var img: String?
    /// 图片
    var img1: String?
    /// 图片
    var notice1: String?
    /// 图片
    var notice2: String?
}

public struct UserService {
    /// 跳转链接
    var action: String?
    /// 角标文案
    var mark: String?
    /// 功能图标
    var icon: String
    /// 功能标题
    var title: String
}

public struct UserInfo: Codable {
    /// 余额
    let balance: String
    /// 头像
    let avatar: String
    /// 头像框
    let avatarFrame: String?
    /// 昵称
    let nickname: String
    /// 蛋壳值
    let eggPoint: String
    /// 通知数
    let notificationCount: String?
    /// 是否需要上传日志
    let needReportLog: Bool?
    /// 能否切换环境
    let canSwitchEnv: Bool?
    /// 是否绑定手机
    let hasBoundPhone: Bool?
    /// 隐藏手机号
    let bindPhoneTip: String?
    /// 手机号
    let phone: String?
    /// 是否是VIP
    let isNDVip: String?
    /// 是否需要提示VIP
    let needNDVipWarning: String?
    /// 用户ID
    let userId: String?
    /// UID
    let uid: String
    /// 经验等级
    let expLevel: String
    /// 经验精度
    let expProgress: String
    /// 经验值
    let expText: String
    /// 是否为黑金卡
    let isBlackGold: String
    /// 头像点击链接
    let userLevelLink: String?
}

extension UserInfoEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserInfoEnvelope> {
        let t = curry(UserInfoEnvelope.init)
        return t
            <^> json <| "userInfo"
            <*> json <||? "banner"
            <*> json <||? "services"
    }
}

extension UserBanner: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserBanner> {
        let t = curry(UserBanner.init)
        return t
            <^> json <| "action"
            <*> json <|? "icon"
            <*> json <|? "img"
            <*> json <|? "img1"
            <*> json <|? "notice1"
            <*> json <|? "notice2"
    }
}

extension UserService: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserService> {
        let t = curry(UserService.init)
        return t
            <^> json <|? "action"
            <*> json <|? "mark"
            <*> json <| "icon"
            <*> json <| "title"
    }
}

extension UserInfo: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<UserInfo> {
        let tmep = curry(UserInfo.init)
        let t1 = tmep <^> json <| "balance"
            <*> json <| "avatar"
            <*> json <|? "avatarFrame"
            <*> json <| "nickname"
        	<*> json <| "eggPoint"
        	<*> json <|? "notificationCount"
        	<*> (json <|? "needReportLog").map(String.toBool)
        	<*> (json <|? "canSwitchEnv").map(String.toBool)
            <*> (json <|? "hasBoundPhone").map(String.toBool)
            <*> json <|? "bindPhoneTip"
            <*> json <|? "phone"
            <*> json <|? "isNDVip"
            <*> json <|? "needNDVipWarning"
            <*> json <|? "userId"
            <*> json <| "uid"
            return t1
            <*> json <| "expLevel"
            <*> json <| "expProgress"
            <*> json <| "expText"
            <*> json <| "isBlackGold"
            <*> json <|? "userLevelLink"
    }
}
