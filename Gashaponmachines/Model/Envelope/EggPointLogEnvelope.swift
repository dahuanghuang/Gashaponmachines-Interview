import Argo
import Curry
import Runes

public struct EggPointLogEnvelope {
    var logs: [EggPointLog]

    struct EggPointLog {
        var description: String
        var createdAt: String
        var increase: String?
        var decrease: String?
    }
}

extension EggPointLogEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<EggPointLogEnvelope> {
        return curry(EggPointLogEnvelope.init)
            <^> json <|| "eggPointLog"
    }
}

extension EggPointLogEnvelope.EggPointLog: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<EggPointLogEnvelope.EggPointLog> {
        return curry(EggPointLogEnvelope.EggPointLog.init)
            <^> json <| "description"
        	<*> json <| "createdAt"
        	<*> json <|? "increase"
        	<*> json <|? "decrease"
    }
}
