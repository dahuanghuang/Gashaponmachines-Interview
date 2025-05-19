import Foundation
import UIKit

struct Constants {

//    static let kAppName          =  "元気扭蛋"
//    static let kAppleId          =  "123"
//    static let kAppleSKU         =  "123"
    static let kAppScheme        =  "Gashaponmachines"
//    static let kAppSourceMarket  =  "AppStore"

    // ShareSDK
    static let kShareSDKAppKey          = "123"

    // Adwords
//    static let kADWORD_GOOGLE_CONVERSION_ID     = "123"
//    static let kADWORD_GOOGLE_LABEL             = "123"

    // CDN
    static let kQINIU_CDN_BASE_URL = "123"

    // Domain
    static let kQUQQI_DOMAIN_URL = "123"

    // Bugtags
    static let kBUG_TAGS_APP_KEY   = "123"

    // UMENG
//    static let kUMENG_TRACK_APP_KEY = "56c6b6ed67e58ef7ac002060"

    static let kDefaultPageLimit = 20
    static let kDefaultPageIndex = 1

    static let kNavigationBarButtonFont: CGFloat = 28
    static let kScreenSize = UIScreen.main.bounds
    static let kScreenWidth = kScreenSize.width
    static let kScreenHeight = kScreenSize.height
    static let kNavHeight: CGFloat = 44
    static let kStatusBarHeight: CGFloat = kScreenHeight >= 812 ? 44 : 20

    static var kScreenTopInset: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.top ?? 0
        } else {
            return 0
        }
    }()

    static var kScreenBottomInset: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0
        } else {
            return 0
        }
    }()

    static var kTabBarHeight: CGFloat = {
        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        }
        return bottomPadding + 49.0
    }()

    static let kBundleName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
}

struct Adapt {
    // 适配宽度(iPhone7)
    static func width(_ width: CGFloat) -> CGFloat {
        return (width / 375) * ScreenSize.SCREEN_WIDTH
    }

    // 适配高度(iPhone7)
    static func height(_ height: CGFloat) -> CGFloat {
        return (height / 667) * ScreenSize.SCREEN_HEIGHT
    }
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6_7        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P_7P      = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    static let IS_IPHONE_X_OR_XS	= UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    static let IS_IPHONE_XR_OR_XS_MAX = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 896.0
    static let IS_IPHONE_X_SERIERS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_HEIGHT / ScreenSize.SCREEN_WIDTH > 1.8
}
