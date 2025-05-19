import Argo
import Curry
import Runes
import RxDataSources

public struct TokenAndKeysEnvelope {
    // 上传图片的 token
    var token: String
    // 上传图片的 key （不带文件名后缀）
    var keys: [String]
    var bucket: String
    var url: String
}

extension TokenAndKeysEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<TokenAndKeysEnvelope> {
        return curry(TokenAndKeysEnvelope.init)
            <^> (json <| "token" <|> pure(""))
            <*> (json <|| "keys" <|> pure([]))
            <*> (json <| "bucket" <|> pure(""))
            <*> (json <| "url" <|> pure(""))
    }
}
