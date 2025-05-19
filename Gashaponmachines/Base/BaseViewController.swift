import UIKit.UIViewController
import RxCocoa
import RxSwift
import Darwin

open class BaseViewController: UIViewController {

    let disposeBag: DisposeBag = DisposeBag()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }

        if let nav = self.navigationController, nav.viewControllers.count > 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButtonItemWith(imageName: "nav_back_white", target: self, selector: #selector(popViewController))
        }

        bindViewModels()

        bindStyles()
    }

    @objc fileprivate func popViewController() {
    	self.navigationController?.popViewController(animated: true)
    }

    open func bindStyles() {
        self.view.backgroundColor = .viewBackgroundColor
    }

    deinit {
        QLog.info(NSStringFromClass(type(of: self)) + " DEINIT😍")
    }

    open func bindViewModels() {

    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
