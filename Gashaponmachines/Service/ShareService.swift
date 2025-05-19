/// 用于管理常见的第三方平台登录及分享的类

public struct Weibo {
    static let appKey: String = "123"
    static let appSecret: String = "123"
    static let redirectURI = "123"
}

class ShareService: NSObject {

    // ShareSDK register
    static func register() {
        ShareSDK.registPlatforms { (register) in
            register?.setupWeChat(withAppId: WXApiManager.appKey, appSecret: WXApiManager.appSecret, universalLink: WXApiManager.universalLink)
            register?.setupSinaWeibo(withAppkey: Weibo.appKey, appSecret: Weibo.appSecret, redirectUrl: Weibo.redirectURI)
        }
    }

    // ShareSDK 图片分享
    static func shareTo(_ platform: SSDKPlatformType, title: String? = "", text: String? = "", shareImage: UIImage? = nil, urlStr: String = "", type: SSDKContentType, callback: ((Bool) -> Void)? = nil) {
        let shareParames = NSMutableDictionary()

        shareParames.ssdkSetupShareParams(byText: text, images: shareImage, url: URL(string: urlStr), title: title, type: type)

        ShareSDK.share(platform, parameters: shareParames) { (state, userData, contentEntity, error) in
            if let error = error {
                QLog.error(error.localizedDescription)
                callback?(false)
            } else {
                switch state {
                case .begin:
                    QLog.debug("begin")
                case .success:
                    callback?(true)
                    HUD.success(second: 2, text: "分享成功", completion: nil)
                case .fail:
                    callback?(false)
                    HUD.showError(second: 2, text: "分享失败", completion: nil)
                case .cancel:
                    callback?(false)
                    HUD.showError(second: 2, text: "取消分享", completion: nil)
                case .upload:
                    QLog.debug("beginUPLoad")
                }
            }
        }
    }
}
