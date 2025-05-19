import UIKit
import Foundation
import RxSwift
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var viewModel: AppDelegateViewModel = AppDelegateViewModel()

    /// 开启网络请求log开关
    static let enabledLog: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 控制台打印开关
        QLog.setupWithLogLevel(.off)

        // 不自动锁屏
        UIApplication.shared.isIdleTimerDisabled = true

        Bugly.start(withAppId: "19c65b3ed4")

        // Bugtags
//        BugtagsService.setup()

        // ShareSDK
        ShareService.register()

        // Alicloud 推送
        PushService.shared.initCloudPush()
        PushService.shared.sendNotificationAck(userInfo: launchOptions)

        // 日志上报
		BugTrackService<SocketEmitEvent>.clearIfExpired()

        AppEnvironment.replaceCurrentEnvironment(
            AppEnvironment.fromStorage()
        )

        // 微信
        WXApiManager.registerApp()
        // UserDefaults.standard.set("004c8347-5866-43c7-a6f4-362fb9a28ac1", forKey: "CONST_USER_ACCESS_TOKEN")

        customizeAppAppearance()

        Setting._saveDefaultValuesAtFirstLaunch()

        let main = LaunchViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = main
        self.window?.makeKeyAndVisible()

        InAppPurchase.shared.completeIAPTransactions()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.viewModel.applicationDidEnterBackground.onNext(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.viewModel.applicationDidBecomeActive.onNext(application)

//        GDTService.startApp()
    }

    // >= ios 9
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return AppRoute.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WXApiManager.shared.handleOpenUniversalLink(userActivity: userActivity)
    }

//    // <= ios
//    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
//        return AppRoute.shared.application(application, open: url)
//    }
//
//    // <= ios 8
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        return AppRoute.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//    }

    // Push notification(Token每次启动都会有, App更新后会变)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let encryptedDataText = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        QLog.debug("didRegisterForRemoteNotificationsWithDeviceToken: \(encryptedDataText)")
        PushService.shared.registerDevice(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        QLog.debug("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushService.shared.sendNotificationAck(userInfo: userInfo)
    }
}

private func customizeAppAppearance() {
    UINavigationBar.appearance().titleTextAttributes = [
        NSAttributedString.Key.font: UIFont.withBoldPixel(36),
        NSAttributedString.Key.foregroundColor: UIColor.white
    ]
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.withPixel(Constants.kNavigationBarButtonFont)], for: [.normal, .highlighted, .disabled, .selected])
    UINavigationBar.appearance().barTintColor = .qu_black
    UINavigationBar.appearance().tintColor = .white
    UINavigationBar.appearance().backgroundColor = .qu_lightGray
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().clipsToBounds = false
}
