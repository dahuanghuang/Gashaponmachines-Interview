// 没用

// import Argo
// import Curry
// import Runes
//
// public struct UserPlayGameEnvelope {
//    var data: UserPlayGameInfo?
//    // 状态码
//    var code: Int?
//    var msg: String?
//
//    // 余额不足 或 其他错误时的 code
//    var errCode: String?
//
//    struct UserPlayGameInfo {
//        var balance: String
//        var orderId: String
//    }
// }
//
// extension UserPlayGameEnvelope: Argo.Decodable {
//    public static func decode(_ json: JSON) -> Decoded<UserPlayGameEnvelope> {
//        return curry(UserPlayGameEnvelope.init)
//            <^> json <|? "data"
//        	<*> json <|? "code"
//        	<*> json <|? "msg"
//        	<*> json <|? "errCode"
//    }
// }
//
// extension UserPlayGameEnvelope.UserPlayGameInfo: Argo.Decodable {
//    public static func decode(_ json: JSON) -> Decoded<UserPlayGameEnvelope.UserPlayGameInfo> {
//        return curry(UserPlayGameEnvelope.UserPlayGameInfo.init)
//            <^> (json <| "balance" <|> (json <| "balance").map(Int.toString))
//    		<*> json <| "orderId"
//    }
// }
