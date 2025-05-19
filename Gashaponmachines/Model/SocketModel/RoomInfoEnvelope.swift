import Argo
import Curry
import Runes

// public struct RoomResultEnvelope {
//    var roomInfo: RoomInfoEnvelope
//    var code: String
//    var msg: String
// }

public struct RoomInfoEnvelope {
    var liveAddress: String
    var luckyEggImage: String
    var luckyEggWorth: String
    var balance: String
    var machinePrice: String
    var powerInfo: PowerInfo?
    var machine: GameMachine?
    var tip: String?

    // 是否是扭蛋会员
    var isNDVip: String?
    // 是否需要扭蛋会员提示弹窗
    var needNDVipWarning: String?
}

public struct GameMachine {
    var icon: String?
    var title: String?
    var type: HomeMachineStyle?
}

public struct PowerInfo {
    // 连击加倍倍数
    var extraMultiple: String?
    // 当前一次游戏可获得的能量
    var canObtainPower: String?
    // 使用的倍数，仅仅用于暴击信息展示(不可做状态判断)
    var critMultiple: String?
    // 能量加速倍数
    var multiples: PowerMultiple?
    // 暴击帮助文档链接
    var noticeUrl: String?
    // 总能获得的能量值上限
    var powerThreshold: Int?
    // 当前总能量值
    var currentPower: Float?
    // 一次暴击需要的能量值
    var critNeeds: Int?
    // 显示在一次暴击需要的能量值左边的那个数字
    var powerReminder: Float?
    // 能量值是否足够暴击至少一次，
    var canCrit: Bool?
    // 可暴击次数
    var canCritCount: Int?
}

public struct PowerMultiple {
    /// 黑金蛋加速器
    var bgdMultiple: String?
    /// 等级加速
    var expMultiple: String?
}

// extension RoomResultEnvelope: Argo.Decodable {
//    public static func decode(_ json: JSON) -> Decoded<RoomResultEnvelope> {
//        return curry(RoomResultEnvelope.init)
//        <^> json <| "roomInfo"
//        <*> json <| "code"
//        <*> json <| "msg"
// }

extension RoomInfoEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<RoomInfoEnvelope> {
        return curry(RoomInfoEnvelope.init)
        <^> json <| "liveAddress"
        <*> json <| "luckyEggImage"
        <*> json <| "luckyEggWorth"
        <*> (json <| "balance" <|> (json <| "balance").map(Int.toString))
        <*> (json <| "machinePrice" <|> (json <| "machinePrice").map(Int.toString))
        <*> json <|? "powerInfo"
        <*> json <|? "machine"
        <*> json <|? "tip"
        <*> json <|? "isNDVip"
        <*> json <|? "needNDVipWarning"
    }
}

extension GameMachine: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GameMachine> {
        return curry(GameMachine.init)
            <^> json <|? "icon"
            <*> json <|? "title"
            <*> json <|? "type"
    }
}

extension PowerInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PowerInfo> {
        let a = curry(PowerInfo.init)
            <^> json <|? "extraMultiple"
            <*> json <|? "canObtainPower"
            <*> json <|? "critMultiple"
            <*> json <|? "multiples"
            <*> json <|? "noticeUrl"
        let a1 = a
            <*> (json <|? "powerThreshold" <|> (json <|? "powerThreshold").map(String.toInt))
            <*> (json <|? "currentPower" <|> (json <|? "currentPower").map(String.toFloat))
            <*> (json <|? "critNeeds" <|> (json <|? "critNeeds").map(String.toInt))
            <*> (json <|? "powerReminder" <|> (json <|? "powerReminder").map(String.toFloat))
            <*> (json <|? "canCrit" <|> (json <|? "canCrit").map(String.toBool))
            <*> (json <|? "canCritCount" <|> (json <|? "canCritCount").map(String.toInt))
        return a1
    }
}

extension PowerMultiple: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PowerMultiple> {
        return curry(PowerMultiple.init)
            <^> json <|? "bgdMultiple"
            <*> json <|? "expMultiple"
    }
}
