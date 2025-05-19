import Argo
import Curry
import Runes

public struct BalanceLogEnvelope {
    var logs: [BalanceLog]

    struct BalanceLog {
        var description: String
        var createdAt: String
        var increase: String?
        var decrease: String?
    }
}

extension BalanceLogEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BalanceLogEnvelope> {
        return curry(BalanceLogEnvelope.init)
            <^> json <|| "balanceLog"
    }
}

extension BalanceLogEnvelope.BalanceLog: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BalanceLogEnvelope.BalanceLog> {
        return curry(BalanceLogEnvelope.BalanceLog.init)
            <^> json <| "description"
            <*> json <| "createdAt"
            <*> json <|? "increase"
            <*> json <|? "decrease"
    }
}
