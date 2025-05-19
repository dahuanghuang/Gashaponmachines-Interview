import QuartzCore
import UIKit

extension UIView {

    /// Animation used in NoticeLabel
    func applyMoveInAnimation() {
        let trans = CATransition()
        trans.duration = 0.33
        trans.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        trans.type = CATransitionType(rawValue: "push")
        trans.subtype = CATransitionSubtype.fromTop
        self.layer.add(trans, forKey: nil)
    }
}
