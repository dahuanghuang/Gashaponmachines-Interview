import Argo
import Runes
import Curry

public struct FAQEnvelope {
    var faq: [FAQ]

    struct FAQ {
        var question: String
        var answer: String
        var isFold: Bool?
    }
}

extension FAQEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<FAQEnvelope> {
        return curry(FAQEnvelope.init)
            <^> json <|| "faq"
    }
}

extension FAQEnvelope.FAQ: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<FAQEnvelope.FAQ> {
        return curry(FAQEnvelope.FAQ.init)
            <^> json <| "question"
            <*> json <| "answer"
            <*> json <|? "isFold"
    }
}
