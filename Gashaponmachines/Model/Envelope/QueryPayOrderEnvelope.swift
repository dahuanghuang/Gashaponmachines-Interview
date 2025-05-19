import Argo
import Curry
import Runes

public struct QueryPayOrderEnvelope: Argo.Decodable {
    var outTradeNumber: String
    var code: String
    var msg: String

    public static func decode(_ json: JSON) -> Decoded<QueryPayOrderEnvelope> {
        return curry(QueryPayOrderEnvelope.init)
            <^> json <| ["data", "outTradeNumber"]
            <*> json <| "code"
            <*> json <| "msg"
    }
}
