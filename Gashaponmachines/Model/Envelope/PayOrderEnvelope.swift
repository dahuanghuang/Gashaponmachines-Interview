import Argo
import Curry
import Runes
import RxSwift

public struct PayOrderEnvelope {
    var sign: String
    var outTradeNum: String

    var prepayId: String?
    var timestamp: String?
    var partnerId: String?
    var nonceStr: String?
}

extension PayOrderEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PayOrderEnvelope> {
        return curry(PayOrderEnvelope.init)
        	<^> json <| "sign"
        	<*> json <| "outTradeNumber"
        	<*> json <|? "prepayId"
        	<*> json <|? "timestamp"
        	<*> json <|? "partnerId"
        	<*> json <|? "nonceStr"
    }
}

//extension ObservableType where Self.E == PayOrderEnvelope {
//    public func mapToWechat() -> Observable<WechatOrderEnvelope> {
//        return self.map { env -> WechatOrderEnvelope in
//            return WechatOrderEnvelope(prepayId: env.prepayId ?? "",
//                                       sign: env.sign,
//                                       timestamp: env.timestamp ?? "",
//                                       partnerId: env.partnerId ?? "",
//                                       outTradeNumber: env.outTradeNum,
//                                       nonceStr: env.nonceStr ?? "")
//        }
//    }
//}
