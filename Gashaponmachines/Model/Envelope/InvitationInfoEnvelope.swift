import Argo
import Runes
import Curry

public struct InvitationInfoEnvelope {
    var qrCode: String
    var invitationCode: String
    var invitationRules: String
    var avatar: String
    var nickname: String
    var inviteCount: String
    var balanceCount: String
    var isReferExist: Bool

    var friends: [InvitedFriend]
}

extension InvitationInfoEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<InvitationInfoEnvelope> {
        let tmp = curry(InvitationInfoEnvelope.init)
        let tmp1 = tmp
            <^> json <| "qrCode"
            <*> json <| "invitationCode"
            <*> json <| "invitationRules"
        let tmp2 = tmp1
            <*> json <| ["user", "avatar"]
        	<*> json <| ["user", "nickname"]
        	<*> json <| ["user", "inviteCount"]
        return tmp2
            <*> json <| ["user", "balanceCount"]
            <*> (json <| "isReferExist" <|> (json <| "isReferExist").map(String.toBool))
        	<*> json <|| "friends"
    }
}
