private class CompositionDetailAnnouncementSubView: UIView {

    lazy var im = UIImageView.with(imageName: "compo_detail_an")

    lazy var label = UILabel.with(textColor: .qu_black, fontSize: 24)

    init(str: String) {
        super.init(frame: .zero)

//        self.backgroundColor = UIColor.UIColorFromRGB(0x26bae5, alpha: 0.2)
        self.backgroundColor = UIColor(hex: "fdc22b", alpha: 0.2)

        self.addSubview(im)
        im.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(15)
            make.left.equalTo(self).offset(12 + 18)
        }

        label.text = str
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(im.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CompositionDetailAnnouncementView: UIView {

    init(strings: [String]) {
        super.init(frame: .zero)
        var topOffset = 12

        let height = 36
        strings.forEach { str in
            let view = CompositionDetailAnnouncementSubView(str: str)
            let width = str.width(withConstrainedHeight: 36, font: UIFont.withPixel(24)) + 18 + 18 + 12 + 15 + 5
            view.layer.cornerRadius = 18
            view.layer.masksToBounds = true
            self.addSubview(view)
            view.snp.makeConstraints { make in
                make.top.equalTo(self).offset(topOffset)
                make.left.equalTo(self).offset(-height/2)
                make.height.equalTo(height)
                make.width.equalTo(width)
            }

            topOffset += 48
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension String {

    /// Calculates the width needed to render the receiver in the given font within the given height.
    /// - Parameters:
    ///    - withConstrainedHeight: The height to use when determining the width.
    ///    - font: The font to use when calculating the width.
    /// - Returns: The width that fits the receiver.
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width * UIScreen.main.scale) / UIScreen.main.scale
    }
}
