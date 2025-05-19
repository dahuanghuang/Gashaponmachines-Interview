import UIKit.UIAlertController

public extension UIAlertController {

    static func cellularWarning(confirmHandler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController.genericConfirm("注意，当前正在使用蜂窝移动数据",
                                                     message: "温馨提示：建议连接到 WiFi 环境，避免出现视频卡顿或音画不同步的情况",
                                                     actionTitle: "好的",
                                                     cancelTitle: "就是任性",
                                                     confirmHandler: confirmHandler)
        return alert
    }

    static func genericAlert(_ title: String, message: String?, actionTitle: String, completionHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: actionTitle,
                style: .cancel,
                handler: completionHandler
            )
        )
        return alertController
    }

    static func genericConfirm(_ title: String,
                                      message: String,
                                      actionTitle: String,
                                      cancelTitle: String,
                                      confirmHandler: @escaping (UIAlertAction) -> Void,
                                      cancelHandler: ((UIAlertAction) -> Void)? = nil
        ) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: actionTitle,
                style: .default,
                handler: confirmHandler
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: cancelTitle,
                style: .cancel,
                handler: { action in
                    cancelHandler
                    alertController.dismiss(animated: true, completion: nil)
            	}
            )
        )
        return alertController
    }
}
