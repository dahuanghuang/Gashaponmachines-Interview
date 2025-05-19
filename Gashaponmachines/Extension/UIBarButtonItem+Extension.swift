import UIKit

extension UIBarButtonItem {
    static func barButtonItemWith(text: String, target: Any?, selector: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(title: text, style: .plain, target: target, action: selector)
    }

    static func barButtonItemWith(imageName: String, target: Any?, selector: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: target, action: selector)
    }
}
