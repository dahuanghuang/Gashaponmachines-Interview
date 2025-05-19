import CloudPushSDK
import UserNotifications

// 第一次注册通知Key
private let PushServiceNotificationDialogDidShowedUpKey = "PushServiceNotificationDialogDidShowedUpKey"
// 第二次注册通知Key(解决阿里云iOS13DeviceToken无法更新的BUG)
private let PushServiceNotificationRegisterAgainKey = "PushServiceNotificationRegisterAgainKey"

// APNS 推送
struct PushService {

    var hasAskForPermission: Bool {
        return AppEnvironment.userDefault.bool(forKey: PushServiceNotificationDialogDidShowedUpKey)
    }

    var isRegisteredForRemoteNotifications: Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }

    static let shared = PushService()

    static var deviceId: String {
        return CloudPushSDK.getDeviceId() ?? ""
    }

    var sdkVersion: String {
        return CloudPushSDK.getVersion()
    }

    func initCloudPush() {
        CloudPushSDK.asyncInit("123", appSecret: "123") { res in
            if let res = res, res.success {
                // 每次启动都回去注册推送通知
                dispatch_sync_safely_main_queue {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                QLog.debug("Push SDK init success, deviceId: \(String(describing: CloudPushSDK.getDeviceId())).")
            } else {
                QLog.error("Push SDK init failed, error.")
            }
        }
    }

    // 第二次注册推送(解决阿里云iOS13DeviceToken无法更新的BUG)
    func registerAPNsAgain() {
        if AppEnvironment.userDefault.bool(forKey: PushServiceNotificationRegisterAgainKey) {
            return
        }
        AppEnvironment.userDefault.set(true, forKey: PushServiceNotificationRegisterAgainKey)
        self.registerAPNS()
    }

    // 第一次注册(正常逻辑)
    func registerAPNS() {
        AppEnvironment.userDefault.set(true, forKey: PushServiceNotificationDialogDidShowedUpKey)
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
                guard error == nil else {
                    QLog.error("注册 APNS 推送服务失败")
                    return
                }
                if granted {
                    QLog.debug("注册 APNS 推送服务成功")
                    dispatch_sync_safely_main_queue {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    QLog.debug("用户推迟 APNS 推送注册")
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            dispatch_sync_safely_main_queue {
                UIApplication.shared.registerUserNotificationSettings(settings)
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func registerIfNeed(on onViewController: UIViewController, confirmClosure: @escaping (() -> Void), cancelClosure: @escaping (() -> Void)) {
        if hasAskForPermission {
            self.registerAPNsAgain()
            return
        }

        let vc = PushNotificationViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.quitButton.rx.tap
        	.asDriver()
            .drive(onNext: {
                vc.dismiss(animated: true, completion: cancelClosure)
            })
        	.disposed(by: vc.disposeBag)
        vc.confirmButton.rx.tap
            .asDriver()
            .drive(onNext: {
                vc.dismiss(animated: true, completion: confirmClosure)
            })
            .disposed(by: vc.disposeBag)
        onViewController.navigationController?.present(vc, animated: true, completion: nil)
    }

    func registerDevice(deviceToken: Data) {
        CloudPushSDK.registerDevice(deviceToken) { res in
            if let res = res, res.success {
                QLog.debug("Register deviceToken success.")
            } else {
                QLog.error("Register deviceToken failed.")
            }
        }
    }

    func syncBadgeNum(count: Int) {
        CloudPushSDK.syncBadgeNum(UInt(count)) { res in

        }
    }

    func sendNotificationAck(userInfo: [AnyHashable: Any]!) {
        CloudPushSDK.sendNotificationAck(userInfo)
    }

    func unregisterAPNS() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}
