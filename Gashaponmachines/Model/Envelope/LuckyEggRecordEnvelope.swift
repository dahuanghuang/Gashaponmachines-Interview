import Argo
import Curry
import Runes

public struct LuckyEggRecordEnvelope {
    var records: [Record]

    struct Record {
        var avatar: String
        var avatarFrame: String?
        var nickname: String
        var luckyTime: String
        var gameVideo: String?
        /// 暴击次数
        var critMultiple: String?
    }
}

extension LuckyEggRecordEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<LuckyEggRecordEnvelope> {
        return curry(LuckyEggRecordEnvelope.init)
        	<^> json <|| "records"
    }
}

extension LuckyEggRecordEnvelope.Record: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<LuckyEggRecordEnvelope.Record> {
        return curry(LuckyEggRecordEnvelope.Record.init)
            <^> json <| "avatar"
            <*> json <|? "avatarFrame"
        	<*> json <| "nickname"
        	<*> json <| "luckyTime"
        	<*> json <|? "gameVideo"
            <*> json <|? "critMultiple"
    }
}
