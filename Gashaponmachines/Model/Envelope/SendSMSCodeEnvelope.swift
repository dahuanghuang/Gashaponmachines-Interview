import Argo
import Runes
import Curry

public struct SendSMSCodeEnvelope {
    var success: String
    var message: String
}

extension SendSMSCodeEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<SendSMSCodeEnvelope> {
        return curry(SendSMSCodeEnvelope.init)
            <^> json <| "success"
            <*> json <| "msg"
    }
}
