import Foundation
import Argo
import Curry
import Runes

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

public struct Config {

    /// 用户协议网页地址(userAgreementURL)
    var siteURLs: [String: String]
    /// 是否为审核
    var isReal: Bool
    /// 是否需要开启一番赏
    var isYfs: Bool
    /// 是否需要开启苹果登录
    var isAppleLogin: Bool
    /// 是否需要展示tabbar点击的动画
    var isAnimation: Bool
    /// 最新版本
    var latestVersion: String
    /// 更新版本描述
    var updateDescription: String
    /// 是否需要打开日志
    var isEnableLog: Bool
    /// 首页右边小弹窗(image, action)
    var floatImageInfo: [String: String]

    init(isReal: Bool, siteURLs: [String: String] = [:], isYfs: Bool, isAppleLogin: Bool, isAnimation: Bool, version: String, desc: String, isEnableLog: Bool, floatImageInfo: [String: String]) {
        self.isReal = isReal
        self.siteURLs = siteURLs
        self.isYfs = isYfs
        self.isAppleLogin = isAppleLogin
        self.isAnimation = isAnimation
        self.latestVersion = version
        self.updateDescription = desc
        self.isEnableLog = isEnableLog
        self.floatImageInfo = floatImageInfo
    }
}
