class RoundedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundCorners(.allCorners, radius: 4)
    }
}

extension RoundedButton {

    static func withRounded(title: String?, titleColor: UIColor?, fontSize: CGFloat) -> RoundedButton {
        let button = RoundedButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.withPixel(fontSize)
        return button
    }
}
