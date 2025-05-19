import AdSupport

public struct DeviceInfo {

    private static func isJailBreak() -> String {
        let filePath = "/Applications/Cydia.app"
        if FileManager.default.fileExists(atPath: filePath) {
            return "1"
        }
        return "0"
    }

    private static func getOSVersion() -> String {
        return ProcessInfo.processInfo.operatingSystemVersionString
    }

    static func getAppVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
    }

    static func getBuildVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleVersion"] as! String
        return version
    }

    private static func getBundleName() -> String {
        let bundleName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
        return bundleName
    }

    /// IDFV: 删除App会重置, 无法保证唯一性
    /// 10.3 版本之后 如果 App 被删除，之前存储于 keychain 中的数据也会一同被清除。
    /// 如果使用了 keychain group，只要当 group 所有相关的 App 被删除时，keychain 中的数据才会被删除。所以以后只能通过追踪 IDFA+IDFV 来分析用户行为(IDFV + keychain保存唯一值方法不可行)
    private static func getDeviceId() -> String {
        if let str = UIDevice.current.identifierForVendor?.uuidString {
            return str
        } else {
            return ""
        }
    }

    /// iOS14及以上, IDFA需要info.plist添加NSUserTrackingUsageDescription提示用户, 用户同意可获取
    private static func getIDFA() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    static func deviceInfo() -> [String: [String: String]] {
        let deviceInfo = ["deviceInfo": ["os_version": getOSVersion(),
                               "is_jailbroken": isJailBreak(),
                               "os": "iOS",
                               "app_version": getAppVersion(),
                               "app_build_version": getBuildVersion(),
                               "package_name": getBundleName(),
                               "deviceId": getDeviceId(),
                               "idfa": getIDFA(),
                               "channel": "AppStore"
            ]]
        return deviceInfo
    }
}
