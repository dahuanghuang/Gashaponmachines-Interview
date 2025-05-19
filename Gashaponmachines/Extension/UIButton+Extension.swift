import UIKit.UIButton
import CoreGraphics

extension UIButton {

    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
        return UIImage()
    }

    func setBackgroundColor(color: UIColor, forUIControlState state: UIControl.State) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
    }
}

extension UIButton {

    static let UIButtonFont96PixelHeight: CGFloat = 32
    static let UIButtonCornerRadius96PixelHeight: CGFloat = 4

    //////////////// 圆角按钮

    static func orangeTextWhiteBackgroundOrangeRoundedButton(title: String, fontSize: CGFloat = UIButtonFont96PixelHeight) -> UIButton {
        let button = UIButton.with(title: title, titleColor: UIColor(hex: "ff7645")!, fontSize: fontSize)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: "ff7645")?.cgColor
        return button
    }

    static func blueTextWhiteBackgroundBlueRoundedButton(title: String, fontSize: CGFloat = UIButtonFont96PixelHeight) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_darkBlue, fontSize: fontSize)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.qu_darkBlue.cgColor
        return button
    }

    static func cyanblueTextWhiteBackgroundCyanBlueRoundedButton(title: String, fontSize: CGFloat = UIButtonFont96PixelHeight) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_black, fontSize: fontSize)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.compos_borderColor.cgColor
        return button
    }

    static func blackTextWhiteBackgroundYellowRoundedButton(title: String, fontSize: CGFloat = UIButtonFont96PixelHeight) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_black, fontSize: fontSize)
        button.layer.cornerRadius = UIButtonCornerRadius96PixelHeight
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.qu_yellow.cgColor
        return button
    }

    static func redTextWhiteBackgroundRedRoundedButton(title: String) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_red, fontSize: UIButtonFont96PixelHeight)
        button.layer.cornerRadius = UIButtonCornerRadius96PixelHeight
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.qu_red.cgColor
        return button
    }

    static func whiteTextRedBackgroundRedRoundedButton(title: String) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .white, fontSize: UIButtonFont96PixelHeight)
        button.layer.cornerRadius = UIButtonCornerRadius96PixelHeight
        button.layer.borderWidth = 1
        button.backgroundColor = .qu_red
        button.layer.borderColor = UIColor.qu_red.cgColor
        return button
    }

    static func whiteTextCyanGreenBackgroundButton(title: String?, fontSize: CGFloat = UIButtonFont96PixelHeight) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .white, fontSize: fontSize)
        button.layer.cornerRadius = UIButtonCornerRadius96PixelHeight
        button.layer.borderWidth = 1
        button.backgroundColor = .qu_cyanGreen
        button.layer.borderColor = UIColor.qu_cyanGreen.cgColor
        return button
    }

    static func whiteTextCyanGreenBackgroundButton(title: String?, boldFontSize: CGFloat) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .white, boldFontSize: boldFontSize)
        button.layer.cornerRadius = UIButtonCornerRadius96PixelHeight
        button.layer.borderWidth = 1
        button.backgroundColor = .qu_cyanGreen
        button.layer.borderColor = UIColor.qu_cyanGreen.cgColor
        return button
    }

    static func cyanGreenTextWhiteBackgroundButton(title: String?) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_cyanGreen, fontSize: UIButtonFont96PixelHeight)
        button.layer.cornerRadius = UIButtonCornerRadius96PixelHeight
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.qu_cyanGreen.cgColor
        return button
    }

    static func blackTextYellowBackgroundYellowRoundedButton(title: String?, fontSize: CGFloat = UIButtonFont96PixelHeight) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_black, fontSize: fontSize)
        button.layer.cornerRadius = UIButtonCornerRadius96PixelHeight
        button.layer.masksToBounds = true
        button.backgroundColor = .qu_yellow
        return button
    }

    static func blackTextYellowBackgroundYellowRoundedButton(title: String?, boldFontSize: CGFloat) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_black, boldFontSize: boldFontSize)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .qu_yellow
        return button
    }

    static func blackTextwhiteBackgroundBlackRoundedButton(title: String) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_black, fontSize: UIButtonFont96PixelHeight)
        button.layer.cornerRadius = UIButtonCornerRadius96PixelHeight
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.qu_lightGray.cgColor
        return button
    }

    static func blackTextwhiteBackgroundBlackRoundedButton(title: String, boldFontSize: CGFloat) -> UIButton {
        let button = UIButton.with(title: title, titleColor: .qu_black, boldFontSize: boldFontSize)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.qu_separatorLine.cgColor
        return button
    }
    
    // MARK: - 新版本UI
    /// 白底黄边
    static func whiteBackgroundYellowRoundedButton(title: String, boldFontSize: CGFloat, titleColor: UIColor? = .black) -> UIButton {
        let button = UIButton.with(title: title, titleColor: titleColor, boldFontSize: boldFontSize)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.new_yellow.cgColor
        return button
    }
    
    /// 黄底填充
    static func yellowBackgroundButton(title: String, boldFontSize: CGFloat, titleColor: UIColor? = .black) -> UIButton {
        let button = UIButton.with(title: title, titleColor: titleColor, boldFontSize: boldFontSize)
        button.layer.cornerRadius = 12
        button.backgroundColor = .new_yellow
        return button
    }

    //////////////// 普通按钮

    static func with(title: String?, titleColor: UIColor?, fontSize: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.withPixel(fontSize)
        return button
    }

    static func with(title: String?, titleColor: UIColor?, boldFontSize: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.withBoldPixel(boldFontSize)
        return button
    }

    static func with(title: String?, titleColor: UIColor?, fontSize: CGFloat, target: Any, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.withPixel(fontSize)
        button.addTarget(target, action: selector, for: .touchUpInside)
        return button
    }

    static func with(imageName: String, target: Any?, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: selector, for: .touchUpInside)
        return button
    }

    static func with(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        return button
    }

    static func simpleTextButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.qu_black, for: .normal)
        button.setTitleColor(.qu_brown, for: .highlighted)
        button.titleLabel?.font = UIFont.withPixel(32)
        return button
    }
}
