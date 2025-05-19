// struct BugtagsService {
//
//    static let appKey = "11afcc36124f942fc54d35c966d4e8b5"
//
//    static let shared = BugtagsService()
//
//    // 默认关闭悬浮球和摇一摇
//    static func setup() {
//        let option = BugtagsOptions()
//        option.trackingNetwork = true
//        option.trackingNetworkURLFilter = Constants.kQUQQI_DOMAIN_URL
//        Bugtags.start(withAppKey: appKey, invocationEvent: BTGInvocationEventNone, options: option)
//    }
//
//    // 开启悬浮球
//    static func openBundle() {
//        Bugtags.setInvocationEvent(BTGInvocationEventBubble)
//    }
//
//    // 开启摇一摇
//    static func openShake() {
//        Bugtags.setInvocationEvent(BTGInvocationEventShake)
//    }
// }
