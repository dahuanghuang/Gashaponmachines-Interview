import RxSwift

protocol WXApiManagerDelegate: class {
    func didReceiveAuthResponse(resp: SendAuthResp)

    func didReceivePayResponse(resp: PayResp)
}

final class WXApiManager: NSObject {

    static let appKey: String = "wxf556c883afa91b45"
    static let appSecret: String = "4a1596b16645a893ff1c08668adb9d35"
    static let universalLink: String = "https://web.quqqi.com/"
    static let kAuthScope = "snsapi_userinfo"
    static let kAuthState = "123"

    weak var delegate: WXApiManagerDelegate?

    static var isWechatInstalled: Bool {
        return WXApi.isWXAppInstalled()
    }

    static let shared = WXApiManager()

    func handleOpenURL(url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }

    func handleOpenUniversalLink(userActivity: NSUserActivity) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    }

    static func registerApp() {
        WXApi.registerApp(appKey, universalLink: universalLink)
    }

    /// 微信登录调用接口
    static func wechatLogin(onViewControlelr: UIViewController) {
        if !WXApiManager.isWechatInstalled {
            HUD.alert(title: "错误", message: "请先安装微信客户端", confirmCompletion: nil)
        } else {
            WXApiManager.wechatLogin(on: onViewControlelr)
        }
    }

    /// 微信支付调用接口
    static func wechatPay(env: WechatOrderEnvelope) {
        let payReq = PayReq()
        payReq.openID = WXApiManager.appKey
        payReq.nonceStr = env.nonceStr
        payReq.sign = env.sign
        payReq.partnerId = env.partnerId
        payReq.timeStamp = UInt32(env.timestamp)!
        payReq.prepayId = env.prepayId
        payReq.package = "Sign=WXPay"
        WXApi.send(payReq)
    }

    // private method
    private static func wechatLogin(on onViewController: UIViewController) {
        let req = SendAuthReq()
        req.scope = WXApiManager.kAuthScope
        req.state = WXApiManager.kAuthState
        WXApi.sendAuthReq(req, viewController: onViewController, delegate: WXApiManager.shared)
    }
}

extension WXApiManager: WXApiDelegate {

    internal func onReq(_ req: BaseReq) {}

    internal func onResp(_ resp: BaseResp) {
        if resp is SendAuthResp {
            if let delegate = delegate {
                delegate.didReceiveAuthResponse(resp: resp as! SendAuthResp)
            }
        } else if resp is PayResp {
            if let delegate = delegate {
                delegate.didReceivePayResponse(resp: resp as! PayResp)
            }
        }
    }
}
