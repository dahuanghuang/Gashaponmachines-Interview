import Argo
import Curry
import Runes

public struct MemberInfoEnvelope {

    struct MemberInfo {
        var nickname: String?
        var avatar: String?
        var uid: String?
        var userId: String?
        var isNDMember: String?
        var restNonVipPlayCount: String?
    }

    var user: MemberInfo?

    var description: [[String]]

    var price: String?

    var notice: String?

    var subNotice: String?
}

extension MemberInfoEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<MemberInfoEnvelope> {
        let djs: Decoded<[JSON]> = json <|| "description"
        let ans: Decoded<[[String]]> = djs >>- {sequence($0.map([String].decode))}
        return curry(MemberInfoEnvelope.init)
            <^> json <|? "user"
            <*> ans
            <*> json <|? ["costNotice", "price"]
            <*> json <|? ["costNotice", "notice"]
            <*> json <|? ["costNotice", "subNotice"]
    }
}

extension MemberInfoEnvelope.MemberInfo: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<MemberInfoEnvelope.MemberInfo> {
        return curry(MemberInfoEnvelope.MemberInfo.init)
            <^> json <|? "nickname"
            <*> json <|? "avatar"
            <*> json <|? "uid"
            <*> json <|? "userId"
            <*> json <|? "isNDMember"
            <*> json <|? "restNonVipPlayCount"
    }
}
