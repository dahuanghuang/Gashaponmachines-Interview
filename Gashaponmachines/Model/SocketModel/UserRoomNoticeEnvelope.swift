// 没用
// import Argo
// import Curry
// import Runes
//
// public struct UserRoomNoticeEnvelope {
//    var extInfo: ExtInfo
//    var type: String
//    var message: String
//
//    struct ExtInfo {
//        var avatar: String?
//        var nickname: String?
//        var objectId: String?
//    }
// }
//
// extension UserRoomNoticeEnvelope: Argo.Decodable {
//    public static func decode(_ json: JSON) -> Decoded<UserRoomNoticeEnvelope> {
//        return curry(UserRoomNoticeEnvelope.init)
//            <^> json <| "extInfo"
//            <*> json <| "type"
//            <*> json <| "message"
//    }
// }
//
// extension UserRoomNoticeEnvelope.ExtInfo: Argo.Decodable {
//    public static func decode(_ json: JSON) -> Decoded<UserRoomNoticeEnvelope.ExtInfo> {
//        return curry(UserRoomNoticeEnvelope.ExtInfo.init)
//            <^> json <|? "avatar"
//            <*> json <|? "nickname"
//            <*> json <|? "objectId"
//    }
// }
