import Argo
import Curry
import Runes
import RxDataSources

public struct ComposeRecord {
    var composeRecordId: String
    var title: String
    var image: String
    var introImages: [String]
    var confirmTime: String
    var originalWorth: String
    var worth: String
    var savingCount: String
}

public struct ComposeRecordListEnvelope {
    var totalSavingCount: Int
    var records: [ComposeRecord]
}

extension ComposeRecord: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ComposeRecord> {
        return curry(ComposeRecord.init)
        	<^> json <| "composeRecordId"
        	<*> json <| "title"
        	<*> json <| "image"
            <*> json <|| "introImages"
            <*> (json <| "confirmTime" <|> pure(""))
            <*> json <| "originalWorth"
            <*> json <| "worth"
        	<*> json <| "savingCount"
    }
}

extension ComposeRecordListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ComposeRecordListEnvelope> {
        return curry(ComposeRecordListEnvelope.init)
        	<^> (json <| "totalSavingCount").map(String.toInt)
        	<*> json <|| "recordList"
    }
}
