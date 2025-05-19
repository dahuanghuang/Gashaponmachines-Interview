import Argo
import Curry
import Runes

public struct WechatOrderEnvelope {
    var prepayId: String
    var sign: String
    var timestamp: String
    var partnerId: String
    var outTradeNumber: String
    var nonceStr: String
}
