import Argo
import Runes
import Curry

public struct BizInitEnvelope {
    var needBindPhoneNotice: String?
    var alternatePhone: String?
}

extension BizInitEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BizInitEnvelope> {
        return curry(BizInitEnvelope.init)
            <^> json <|? "needBindPhoneNotice"
            <*> json <|? "alternatePhone"
    }
}
