import Argo
import Curry
import Runes

public struct MallProductExchangeRecordsEnvelope {
    var records: [Record]

    struct Record {
        var title: String
        var decrease: String
        var exchangeTime: String
    }
}

extension MallProductExchangeRecordsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallProductExchangeRecordsEnvelope> {
        return curry(MallProductExchangeRecordsEnvelope.init)
            <^> json <|| "records"
    }
}

extension MallProductExchangeRecordsEnvelope.Record: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallProductExchangeRecordsEnvelope.Record> {
        return curry(MallProductExchangeRecordsEnvelope.Record.init)
            <^> json <| "title"
            <*> json <| "decrease"
            <*> json <| "exchangeTime"
    }
}
