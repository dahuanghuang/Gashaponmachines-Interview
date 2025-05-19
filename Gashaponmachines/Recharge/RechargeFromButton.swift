class RechargeFromButton: UIButton {

    let icon = UIImageView()
    let selectedIcon = UIImageView()
    let titleLbl = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    let subTitleLabel = UILabel.with(textColor: .new_brown, fontSize: 24)

    var method: PaymentMethod

    init(method: PaymentMethod) {
        self.method = method
        super.init(frame: .zero)

        self.isUserInteractionEnabled = true
        
        self.backgroundColor = .clear
        self.layer.borderColor = UIColor.new_backgroundColor.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        self.addSubview(icon)
        self.addSubview(selectedIcon)
        self.addSubview(titleLbl)
        self.addSubview(subTitleLabel)

        selectedIcon.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.left.equalTo(self).offset(12)
            make.centerY.equalTo(self)
        }

        icon.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.left.equalTo(selectedIcon.snp.right).offset(20)
            make.centerY.equalTo(self)
        }

        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(8)
            make.centerY.equalTo(self)
        }
        
        let rightStar = UIImageView(image: UIImage(named: "recharge_star"))
        self.addSubview(rightStar)
        rightStar.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(subTitleLabel)
            make.size.equalTo(16)
        }

        subTitleLabel.textAlignment = .right
        subTitleLabel.snp.makeConstraints { make in
            make.right.equalTo(rightStar.snp.left).offset(-2)
            make.centerY.equalTo(self)
        }
        
        let leftStar = UIImageView(image: UIImage(named: "recharge_star"))
        self.addSubview(leftStar)
        leftStar.snp.makeConstraints { make in
            make.right.equalTo(subTitleLabel.snp.left).offset(-2)
            make.centerY.equalTo(subTitleLabel)
        }

        self.icon.gas_setImageWithURL(method.icon)
        self.titleLbl.text = method.title
        self.subTitleLabel.text = method.subTitle
        self.selectedIcon.image = UIImage(named: "login_unselect")
        rightStar.isHidden = (method.subTitle == "")
        leftStar.isHidden = (method.subTitle == "")
    }

    override var isSelected: Bool {
        didSet {
            self.selectedIcon.image = isSelected ?  UIImage(named: "recharge_selected") : UIImage(named: "login_unselect")
            self.backgroundColor = isSelected ? .new_bgYellow : .clear
            self.layer.borderColor = isSelected ? UIColor.clear.cgColor : UIColor.new_backgroundColor.cgColor
            self.layer.borderWidth = isSelected ? 0 : 1
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
