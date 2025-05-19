class DeliveryRecordDetailCardInfoView: UIView {
    
    var isLast = false

    init(cyberInfo: ShipDetailEnvelope.CyberInfo, isLast: Bool) {
        super.init(frame: .zero)
        
        self.isLast = isLast
        
        self.backgroundColor = .white
        
        let bgView = UIView.withBackgounrdColor(.new_backgroundColor.alpha(0.4))
        bgView.layer.cornerRadius = 8
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(isLast ? -12 : -8)
        }

        var lastView: UIView = self

        if let cardNum = cyberInfo.cardNoText, let num = cyberInfo.cardNo {

            let label = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: cardNum)
            bgView.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(40)
                make.left.equalTo(4)
            }

            let button = CopyButton.roundButton()
            button.params = ["num": num]
            button.addTarget(self, action: #selector(copyCardNum(button:)), for: .touchUpInside)
            bgView.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalTo(label)
                make.width.equalTo(44)
                make.height.equalTo(18)
                make.right.equalToSuperview().offset(-8)
            }

            lastView = label
        }

        if let cardPwd = cyberInfo.cardPwText, let pwd = cyberInfo.cardPw {

            let label = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: cardPwd)
            bgView.addSubview(label)
            label.snp.makeConstraints { make in
                make.height.equalTo(40)
                if lastView is UILabel {
                    make.top.equalTo(lastView.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.equalToSuperview().offset(4)
            }

            let button = CopyButton.roundButton()
            button.params = ["pwd": pwd]
            button.addTarget(self, action: #selector(copyCardPwd(button:)), for: .touchUpInside)
            bgView.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalTo(label)
                make.width.equalTo(44)
                make.height.equalTo(18)
                make.right.equalToSuperview().offset(-8)
            }

            lastView = label
        }

        if let cardCode = cyberInfo.cardCodeText, let code = cyberInfo.cardCode {

            let label = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: cardCode)
            bgView.addSubview(label)
            label.snp.makeConstraints { make in
                make.height.equalTo(40)
                if lastView is UILabel {
                    make.top.equalTo(lastView.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.equalToSuperview().offset(4)
            }

            let button = CopyButton.roundButton()
            button.params = ["code": code]
            button.addTarget(self, action: #selector(copyCardCode(button:)), for: .touchUpInside)
            bgView.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalTo(label)
                make.width.equalTo(44)
                make.height.equalTo(18)
                make.right.equalToSuperview().offset(-8)
            }

            lastView = label
        }
    }

    @objc func copyCardNum(button: CopyButton) {
        let paste = UIPasteboard.general
        paste.string = button.params["num"] as? String
        HUD.success(second: 2, text: "复制成功", completion: nil)
    }

    @objc func copyCardCode(button: CopyButton) {
        let paste = UIPasteboard.general
        paste.string = button.params["code"] as? String
        HUD.success(second: 2, text: "复制成功", completion: nil)
    }

    @objc func copyCardPwd(button: CopyButton) {
        let paste = UIPasteboard.general
        paste.string = button.params["pwd"] as? String
        HUD.success(second: 2, text: "复制成功", completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isLast {
            self.roundCorners([.bottomLeft, .bottomRight], radius: 12)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CopyButton: UIButton {
    var params: [String: Any]
    override init(frame: CGRect) {
        self.params = [:]
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.params = [:]
        super.init(coder: aDecoder)
    }

    static func roundButton() -> CopyButton {
        let button = CopyButton()
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor(hex: "FFCC3E")?.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.UIColorFromRGB(0xD29F26), for: .normal)
        button.setTitle("复制", for: .normal)
        button.setBackgroundColor(color: .clear, forUIControlState: .normal)
        button.titleLabel?.font = UIFont.withPixel(20)
        return button
    }
}
