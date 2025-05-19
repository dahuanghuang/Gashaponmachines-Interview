class OccupyRechargeOptionButton: UIImageView {

    var isSelected: Bool = false {
        didSet {
            self.backgroundColor = isSelected ? UIColor(hex: "FFDA60") : .new_bgYellow
            self.topContainer.backgroundColor = isSelected ? .new_bgYellow : .white
            self.bottomContainer.backgroundColor = isSelected ? .new_bgYellow.alpha(0.6) : .white.alpha(0.6)
            self.titleLbl.textColor = isSelected ? UIColor(hex: "9A4312") : UIColor(hex: "D29F26")
            self.priceLabel.textColor = isSelected ? .black : UIColor(hex: "9A4312")
        }
    }

    let topContainer = RoundedCornerView(corners: [.topLeft, .topRight], radius: 6, backgroundColor: .white)
    
    let bottomContainer = RoundedCornerView(corners: [.bottomLeft, .bottomRight], radius: 6, backgroundColor: .white.alpha(0.6))

    let icon = UIImageView()

    let titleLbl = UILabel.with(textColor: UIColor(hex: "D29F26")!, boldFontSize: 28)

    let priceLabel = UILabel.with(textColor: UIColor(hex: "9A4312")!, boldFontSize: 24)

    var option: PaymentOption

    let fakeButton = PassableUIButton()

    init(frame: CGRect, option: PaymentOption) {
        self.option = option
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = .new_bgYellow
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        self.addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.top.left.equalTo(2)
            make.right.equalTo(-2)
            make.height.equalTo(66)
        }

        self.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.left.right.equalTo(topContainer)
            make.bottom.equalTo(-2)
            make.top.equalTo(topContainer.snp.bottom).offset(2)
        }

        self.addSubview(icon)
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(20)
        }

        topContainer.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        bottomContainer.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.titleLbl.text = option.title
        self.priceLabel.text = "¥\(option.amount)"

        if let URL = URL(string: option.icon) {
            self.icon.qu_setImageWithURL(URL)
        }

        fakeButton.params["amount"] = option.amount
        self.addSubview(fakeButton)
        fakeButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    deinit {
        self.icon.cancelNetworkImageDownloadTask()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
