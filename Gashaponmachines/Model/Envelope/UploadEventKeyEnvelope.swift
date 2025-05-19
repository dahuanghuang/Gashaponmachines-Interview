import Argo
import Runes
import Curry

public struct UploadEventKeyEnvelope {
    var key: String
    var token: String
}

extension UploadEventKeyEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UploadEventKeyEnvelope> {
        return curry(UploadEventKeyEnvelope.init)
            <^> json <| "key"
            <*> json <| "token"
    }
}
