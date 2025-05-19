import JGProgressHUD
import Toast_Swift

struct HUD {

    static let shared = HUD()

    private var hud = JGProgressHUD(style: .dark)

    //
    func persist(text: String, timeout: TimeInterval = 0) {
        if let window = UIApplication.shared.keyWindow {
            self.hud.textLabel.text = text
            if timeout != 0 {
                self.hud.dismiss(afterDelay: timeout)
            }
            self.hud.show(in: window)
        }
    }

    func dismiss() {
        self.hud.dismiss()
    }

    func progress(percent: Float, animated: Bool) {
        let HUD = JGProgressHUD(style: .dark)
        HUD.indicatorView = JGProgressHUDPieIndicatorView()
        HUD.setProgress(percent, animated: animated)
        if let window = UIApplication.shared.keyWindow {
            HUD.show(in: window)
            HUD.dismiss(afterDelay: 10)
        }
    }

    static func showError(second: Double = 2, text: String? = "错误", completion: (() -> Void)?) {
        QLog.error(text)
        if let window = UIApplication.shared.keyWindow {
            let hud = JGProgressHUD(style: .dark)
            let indicatorView = JGProgressHUDErrorIndicatorView()
            hud.indicatorView = indicatorView
            hud.textLabel.text = text
            hud.show(in: window)
            delay(second) {
                hud.dismiss()
                if let closure = completion {
                    closure()
                }
            }
        }
    }

    static func showResultEnvelope(env: ResultEnvelope) {
    	HUD.showError(second: 2, text: env.msg, completion: nil)
    }

    static func showErrorEnvelope(env: ErrorEnvelope) {
        if env.code == String(GashaponmachinesError.notLogin.rawValue) {
            HUD.showError(second: 2, text: env.msg) {
                AppEnvironment.logout()
            }
        } else if env.code == String(GashaponmachinesError.success.rawValue) {
            HUD.success(second: 2, text: env.msg, completion: nil)
        } else {
            HUD.showError(second: 2, text: env.msg, completion: nil)
        }
    }

    static func success(second: Double = 1.5, text: String? = "完成", completion: (() -> Void)?) {
        if let window = UIApplication.shared.keyWindow {
            let hud = JGProgressHUD(style: .dark)
            let indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.indicatorView = indicatorView
            hud.textLabel.text = text
            hud.show(in: window)
            delay(second) {
                hud.dismiss()
                if let closure = completion {
                    closure()
                }
            }
        }
    }

    static func alert(title: String, message: String? = nil, confirmCompletion: ((UIAlertAction) -> Void)? = nil) {
        if let window = UIApplication.shared.keyWindow, let root = window.rootViewController {
            if let top = UIApplication.topViewController(base: root) {
                if top.topMostViewController is UIAlertController {
                    return
                }
                let vc = UIAlertController.genericAlert(title, message: message, actionTitle: "好的", completionHandler: confirmCompletion)
//                vc.modalPresentationStyle = .fullScreen
                top.present(vc, animated: true, completion: nil)
            }
        }
    }
}
