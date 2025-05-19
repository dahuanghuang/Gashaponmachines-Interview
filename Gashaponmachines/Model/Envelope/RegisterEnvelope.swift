import Argo
import Runes
import Curry

public struct RegisterEnvelope {
    var sessionToken: String
    var user: User
}

extension RegisterEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<RegisterEnvelope> {
        return curry(RegisterEnvelope.init)
            <^> json <| "sessionToken"
        	<*> json <| "userInfo"
    }
}
