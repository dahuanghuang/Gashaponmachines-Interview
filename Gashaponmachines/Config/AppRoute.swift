/// 用于不同 App 之间的跳转，应用内页面跳转请使用 RouterService 类
struct AppRoute {
    static let shared = AppRoute()

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        if let identifier = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String {
            if identifier == "com.tencent.xin" {
                return WXApiManager.shared.handleOpenURL(url: url)
            } else if identifier == "com.alipay.iphoneclient" {
                AlipayApiManager.shared.processOrderWithPaymentResult(url: url)
            } else if identifier == Bundle.main.bundleIdentifier! {
                RouterService.route(to: url)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                } else {
                    HUD.showError(second: 2, text: "Can't open URL: \(url)", completion: nil)
                    QLog.error("Can't open URL: \(url)")
                }
            }
        }

        /// 微信登录跳转
        if #available(iOS 13.0, *) {
            if url.absoluteString.contains(WXApiManager.appKey) {
                return WXApiManager.shared.handleOpenURL(url: url)
            }
        }

        /// 支付宝订单查询
        if #available(iOS 13.0, *) {
            if let host = url.host, host == "safepay" {
                AlipayApiManager.shared.processOrderWithPaymentResult(url: url)
            }
        }

        return true
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
}
