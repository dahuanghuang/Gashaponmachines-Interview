class OccupyRechargeErrorView: DimBackgroundView {

    lazy var iv = UIImageView.with(imageName: "game_rc_recharge")

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "霸机充值重连提示")

    lazy var desLabel1: UILabel = {
        let l = UILabel.with(textColor: .qu_black, fontSize: 24)
        l.textAlignment = .left
        l.numberOfLines = 0
        let string = "- 若已充值成功，请不要关闭充值弹窗，霸机充值流程倒计时结束后会自动开始游戏"
        let attributedString = NSMutableAttributedString(string: string, attributes: nil)
        let highlightedRange = (attributedString.string as NSString).range(of: "请不要关闭充值弹窗")
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: highlightedRange)
        l.attributedText = attributedString
        l.preferredMaxLayoutWidth = 280-34-34
        l.setLineSpacing(lineHeightMultiple: 1.5)
        return l
    }()

    lazy var desLabel2: UILabel = {
        let l = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "- 若未完成充值，请继续完成充值流程")
        l.textAlignment = .left
        return l
    }()

    fileprivate lazy var closeButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "好的")

    override init(frame: CGRect) {
        super.init(frame: .zero)

        let contentView = RoundedCornerView(corners: .allCorners, radius: 4)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalToSuperview()
        }

        contentView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(50)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        contentView.addSubview(desLabel1)
        desLabel1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(34)
            make.top.equalTo(titleLabel.snp.bottom).offset(44)
        }

        contentView.addSubview(desLabel2)
        desLabel2.snp.makeConstraints { make in
            make.top.equalTo(desLabel1.snp.bottom).offset(5)
            make.left.equalTo(desLabel1)
        }

        contentView.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.width.equalTo(315/2)
            make.height.equalTo(48)
            make.top.equalTo(desLabel2.snp.bottom).offset(36)
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
    }

    @objc func hide() {
        removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
