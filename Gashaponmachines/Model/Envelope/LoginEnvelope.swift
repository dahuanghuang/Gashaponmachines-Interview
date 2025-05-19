import Runes
import Curry
import Argo

public struct LoginEnvelope {
    var code: String
    var msg: String
    var sessionToken: String
    var user: User
    var isNew: String?
    var fromAd: String?
}

extension LoginEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<LoginEnvelope> {
        let tmp = curry(LoginEnvelope.init)
        let tmp1 = tmp
        <^> json <| "code"
        <*> json <| "msg"
        <*> json <| ["data", "sessionToken"]
        <*> json <| ["data", "userInfo"]
        <*> json <|? ["data", "isNew"]
        <*> json <|? ["data", "fromAd"]
        return tmp1
    }
}
