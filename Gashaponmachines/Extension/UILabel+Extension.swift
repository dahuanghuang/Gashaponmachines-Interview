import UIKit

extension UILabel {
    static func with(textColor: UIColor, boldFontSize: CGFloat, defaultText: String? = nil) -> UILabel {
        let label = UILabel()
        label.font = UIFont.withBoldPixel(boldFontSize)
        label.textColor = textColor
        label.text = defaultText
        return label
    }

    static func with(textColor: UIColor, fontSize: CGFloat, defaultText: String? = nil) -> UILabel {
        let label = UILabel()
        label.font = UIFont.withPixel(fontSize)
        label.textColor = textColor
        label.text = defaultText
        return label
    }
    
    /// 数字Label
    static func numberFont(size: CGFloat, defaultText: String? = nil) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "BebasNeue-Regular", size: size)
        label.text = defaultText
        return label
    }
}

extension UILabel {

    func getLineHeight() -> CGFloat {
        return self.font.lineHeight
    }
}

extension UILabel {

    func addStrikeThroughLine(with text: String?) {
        if let text = text {
            self.text = text
            let str = NSMutableAttributedString(string: text)
            str.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: text.count))
            self.attributedText = str
        }
    }
}

extension UILabel {
    func setText(_ text: String?, lineSpacing: CGFloat) {
        if let text = text, lineSpacing >= 0.01 {
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttributes([NSAttributedString.Key.font: 14], range: NSRange(location: 0, length: attributedString.length))

            let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.lineBreakMode = self.lineBreakMode
            paragraphStyle.alignment = self.textAlignment
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributedString.length))
        }
        self.text = text

    }
}

// 设置行距
extension UILabel {

    // Pass value for any one of both parameters and see result
    func setLineSpacing(_ lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing - (self.font.lineHeight - self.font.pointSize)
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: self.text ?? "")
        }

        // Line spacing attribute
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
}
