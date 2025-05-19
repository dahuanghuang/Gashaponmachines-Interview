import UIKit.UIFont
import UIKit

extension UIFont {

    static func withPixel(_ pixel: CGFloat) -> UIFont {
        return self.systemFont(ofSize: pixel / 2)
    }

    static func withBoldPixel(_ pixel: CGFloat) -> UIFont {
        return self.boldSystemFont(ofSize: pixel / 2)
    }

    static func heightOfPixel(_ pixel: CGFloat) -> CGFloat {
        return self.withPixel(pixel).lineHeight
    }

    static func heightOfBoldPixel(_ pixel: CGFloat) -> CGFloat {
    	return self.withBoldPixel(pixel).lineHeight
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return NSString(string: string).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: self],
            context: nil).size
    }
}

extension UIFont {
    /// 数字字体
    static func numberFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "BebasNeue-Regular", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}
