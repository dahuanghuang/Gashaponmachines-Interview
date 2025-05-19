class PassableUIButton: UIButton {
    var params: [String: Any]
    override init(frame: CGRect) {
        self.params = [:]
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.params = [:]
        super.init(coder: aDecoder)
    }

    static func roundButton() -> PassableUIButton {
        let button = PassableUIButton()
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.setTitleColor(.qu_black, for: .normal)
        button.setTitle("复制", for: .normal)
        button.setBackgroundColor(color: .qu_yellow, forUIControlState: .normal)
        button.titleLabel?.font = UIFont.withPixel(24)
        return button
    }
}
