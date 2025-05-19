import UIKit

final class NavigationController: UINavigationController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 解决iOS15导航栏设置barTintColor和tintColor不显示问题
        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithDefaultBackground()
            navBarAppearance.backgroundColor = .qu_black
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = !self.viewControllers.isEmpty
        super.pushViewController(viewController, animated: animated)
    }
}

extension NavigationController {

    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 禁止调用rootViewController的返回手势, 防止出现右滑手势引起死机问题
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 ||
                self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        return true
    }
}

extension GameNewViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.navigationBar.alpha = 0
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        } else {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.alpha = 1
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        }
    }
}
