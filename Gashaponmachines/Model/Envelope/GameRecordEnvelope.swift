import Argo
import Runes
import Curry

public struct GameRecordEnvelope {
    var types: [GameRecordType]
    var records: [GameRecord]

    struct GameRecordType {
        var type: String?
        var name: String?
    }

    struct GameRecord {
        // 商品名称
        var title: String
        // 商品图片
        var image: String
        // 扭蛋 icon
        var icon: String
        // 游戏日期
        var luckyTime: String
        // 机台图片
        var machineIcon: String?
        // 机台黑蛋图片，这张图和上面的机台图拼成一张图，具体见设计
        var machineImage: String?
        // 该次获得的能量
        var powerObtain: String?
        // 消耗的能量
        var powerCost: String?
        // 暴击倍数
        var critMultiple: String?
    }
}

extension GameRecordEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GameRecordEnvelope> {
        return curry(GameRecordEnvelope.init)
            <^> json <|| "machineTypeList"
            <*> json <|| "gameRecords"
    }
}

extension GameRecordEnvelope.GameRecordType: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GameRecordEnvelope.GameRecordType> {
        return curry(GameRecordEnvelope.GameRecordType.init)
            <^> json <| "type"
            <*> json <| "name"
    }
}

extension GameRecordEnvelope.GameRecord: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GameRecordEnvelope.GameRecord> {
        return curry(GameRecordEnvelope.GameRecord.init)
            <^> json <| "title"
        	<*> json <| "image"
            <*> json <| "icon"
        	<*> json <| "luckyTime"
            <*> json <|? "machineIcon"
            <*> json <|? "machineImage"
            <*> json <|? "powerObtain"
            <*> json <|? "powerCost"
            <*> json <|? "critMultiple"
    }
}
