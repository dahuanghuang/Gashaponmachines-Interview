class InviteSectionView: UIView {

    static let Height: CGFloat = 32 + UIFont.heightOfBoldPixel(32)

    let button = UIButton.with(title: " ", titleColor: .qu_lightGray, fontSize: 28)
    let indicator = UIImageView(image: UIImage(named: "invite_indicator"))
    let label = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "我的好友")

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .qu_yellow

        let container = UIView.withBackgounrdColor(.white)
		self.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalTo(self).offset(8)
            make.right.equalTo(self).offset(-8)
            make.top.bottom.equalTo(self)
        }

        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(container).offset(16)
            make.bottom.equalTo(container).offset(-16)
            make.left.equalTo(container).offset(20)
        }

        let line = UIView.withBackgounrdColor(.qu_yellow)
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.top.equalTo(container)
            make.height.equalTo(0.5)
        }
    }

    func updateInviteCount(count: String) {
        if let num = Int(count), num >= 10, !self.subviews.contains(button), !self.subviews.contains(indicator) {
            self.addSubview(indicator)
            indicator.snp.makeConstraints { make in
                make.right.equalTo(self).offset(-20)
                make.centerY.equalTo(label)
                make.width.equalTo(12)
                make.height.equalTo(25)
            }

            self.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalTo(label)
                make.right.equalTo(indicator.snp.left).offset(-4)
            }
            button.setTitle("共\(count)位，查看全部", for: .normal)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
