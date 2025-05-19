// 没用

// import Argo
// import Curry
// import Runes
//
// public struct UserRechargeEnvelope {
//
//    var data: UserRechargeInfo?
//    var code: Int
//    var msg: String
//    struct UserRechargeInfo {
//        var jobId: String
//    }
// }
//
// extension UserRechargeEnvelope: Argo.Decodable {
//    public static func decode(_ json: JSON) -> Decoded<UserRechargeEnvelope> {
//        return curry(UserRechargeEnvelope.init)
//            <^> json <|? "data"
//            <*> json <| "code"
//        	<*> json <| "msg"
//    }
// }
//
// extension UserRechargeEnvelope.UserRechargeInfo: Argo.Decodable {
//    public static func decode(_ json: JSON) -> Decoded<UserRechargeEnvelope.UserRechargeInfo> {
//        return curry(UserRechargeEnvelope.UserRechargeInfo.init)
//            <^> ((json <| "jobId") <|> (json <| "jobId").map(Int.toString))
//    }
// }
