import Argo
import Curry
import Runes

public struct UserGameRecordEnvelope {
    var avatar: String
    var nickname: String
    var gameRecords: [GameRecord]

    struct GameRecord {
        var title: String
        var image: String
        var type: String
        var confirmDate: String
    }
}

extension UserGameRecordEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserGameRecordEnvelope> {
        return curry(UserGameRecordEnvelope.init)
            <^> json <| "avatar"
            <*> json <| "nickname"
        	<*> json <|| "gameRecords"
    }
}

extension UserGameRecordEnvelope.GameRecord: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserGameRecordEnvelope.GameRecord> {
        return curry(UserGameRecordEnvelope.GameRecord.init)
            <^> json <| "title"
            <*> json <| "image"
            <*> json <| "type"
        	<*> json <| "confirmDate"
    }
}
