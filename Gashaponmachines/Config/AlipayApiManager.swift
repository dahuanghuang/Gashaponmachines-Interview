import Argo
import Runes
import Curry

protocol AlipayApiManagerDelegate: class {

    func didReceiveOutTradeNumber(num: String)
    func didCancelRecharge()
}

class AlipayApiManager: NSObject {

    static let shared = AlipayApiManager()

    weak var delegate: AlipayApiManagerDelegate?

    // App跳转支付宝
    func payOrder(orderStr: String, callback: @escaping CompletionBlock) {
        AlipaySDK.defaultService().payOrder(orderStr, fromScheme: Constants.kAppScheme, callback: callback)
    }

    // 支付宝跳转App后
    func processOrderWithPaymentResult(url: URL) {
        AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { result in

            guard let resultDic = result as? [String: Any], JSONSerialization.isValidJSONObject(resultDic) else {
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: resultDic, options: .prettyPrinted)
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                if json?["resultStatus"] as? String == "6001" { // 取消支付
                    HUD.showError(second: 2, text: "取消支付", completion: nil)
                    self.delegate?.didCancelRecharge()
                } else if json?["resultStatus"] as? String == "9000"{ // 成功
                    let resultStr = json?["result"] as? String
                    if let data = resultStr?.data(using: .utf8) {
                        do {
                            let innerJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                            let alipay_trade_app_pay_response = innerJSON?["alipay_trade_app_pay_response"] as? [String: Any]
                            if let outTradeNumber = alipay_trade_app_pay_response?["out_trade_no"] as? String {
                                self.delegate?.didReceiveOutTradeNumber(num: outTradeNumber)
                            }
                        } catch {
                            QLog.error(error.localizedDescription)
                        }
                    }
                }
            } catch {
                QLog.error(error.localizedDescription)
            }
        })
    }
}

struct AlipayResponse {
    var status: String
    var result: AlipayTradeAppResponse

    struct AlipayTradeAppResponse {
        var code: String
        var msg: String
        var outTradeNumber: String
    }
}

extension AlipayResponse.AlipayTradeAppResponse: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<AlipayResponse.AlipayTradeAppResponse> {
        return curry(AlipayResponse.AlipayTradeAppResponse.init)
            <^> json <| "code"
            <*> json <| "msg"
            <*> json <| "out_trade_no"
    }
}

extension AlipayResponse: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<AlipayResponse> {
        return curry(AlipayResponse.init)
        <^> json <| "resultStatus"
        <*> json <| "result"
    }
}
