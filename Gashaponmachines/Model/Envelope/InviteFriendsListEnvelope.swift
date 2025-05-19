import Argo
import Runes
import Curry

struct InvitedFriend {
    var avatar: String
    var nickname: String
    var hasFinishedInvitation: Bool
    var giftBalance: String
}

public struct InviteFriendsListEnvelope {
    var friends: [InvitedFriend]
}

extension InviteFriendsListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<InviteFriendsListEnvelope> {
        return curry(InviteFriendsListEnvelope.init)
            <^> json <|| "friends"
    }
}

extension InvitedFriend: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<InvitedFriend> {
        return curry(InvitedFriend.init)
            <^> json <| "avatar"
            <*> json <| "nickname"
            <*> (json <| "hasFinishedInvitation" <|> (json <| "hasFinishedInvitation").map(String.toBool))
            <*> json <| "giftBalance"
    }
}
