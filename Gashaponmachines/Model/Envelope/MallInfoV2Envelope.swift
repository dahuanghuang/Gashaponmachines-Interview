import Argo
import Curry
import Runes

public struct MallInfoV2Envelope {

    var balance: String

    var hasOrderRecord: String

    var icons: [Icon]

    var luckyPointRank: [LuckyPointRank]

    var collections: [MallCollection]

    struct Icon {
        var title: String
        var image: String
        var action: String
    }

    struct LuckyPointRank {
        var nickname: String?
        var avatar: String?
        var action: String?
    }
}

struct MallCollection {
    var title: String
    var image: String
    var mallCollectionId: String?
}

extension MallInfoV2Envelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallInfoV2Envelope> {
        return curry(MallInfoV2Envelope.init)
            <^> json <| "balance"
            <*> json <| "hasOrderRecord"
            <*> json <|| "icons"
        	<*> json <|| "luckyPointRank"
        	<*> json <|| "mallCollections"
    }
}

extension MallInfoV2Envelope.Icon: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallInfoV2Envelope.Icon> {
        return curry(MallInfoV2Envelope.Icon.init)
            <^> json <| "title"
            <*> json <| "image"
            <*> json <| "action"
    }
}

extension MallInfoV2Envelope.LuckyPointRank: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallInfoV2Envelope.LuckyPointRank> {
        return curry(MallInfoV2Envelope.LuckyPointRank.init)
            <^> json <|? "nickname"
            <*> json <|? "avatar"
        	<*> json <|? "action"
    }
}

extension MallCollection: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MallCollection> {
        return curry(MallCollection.init)
            <^> json <| "title"
            <*> json <| "image"
            <*> json <|? "mallCollectionId"
    }
}
