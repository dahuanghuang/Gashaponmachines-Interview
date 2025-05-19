// 没用
class ChatMessageLabel: UILabel {

    static let maxWidth = Constants.kScreenWidth - 12 - 40 - 8 - 152/2

    override func drawText(in rect: CGRect) {
        let inset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        super.drawText(in: rect.inset(by: inset))
    }

    override func draw(_ rect: CGRect) {
        roundCorners(.allCorners, radius: 8)
        super.draw(rect)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.withPixel(32)
        preferredMaxLayoutWidth = ChatMessageLabel.maxWidth
        numberOfLines = 0
        textColor = .qu_black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
