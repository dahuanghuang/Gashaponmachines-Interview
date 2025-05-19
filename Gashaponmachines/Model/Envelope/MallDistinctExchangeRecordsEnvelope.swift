import Argo
import Runes
import Curry

public struct MallDistinctExchangeRecordsEnvelope {
    var title: String?
    var records: [Record]

    struct Record {
        var title: String
        var image: String
        var worth: String
        var productId: String?

    }
}

extension MallDistinctExchangeRecordsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallDistinctExchangeRecordsEnvelope> {
        return curry(MallDistinctExchangeRecordsEnvelope.init)
            <^> json <|? "title"
            <*> json <|| "records"
    }
}

extension MallDistinctExchangeRecordsEnvelope.Record: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallDistinctExchangeRecordsEnvelope.Record> {
        return curry(MallDistinctExchangeRecordsEnvelope.Record.init)
            <^> json <| "title"
            <*> json <| "image"
            <*> json <| "worth"
        	<*> json <|? "productId"
    }
}
