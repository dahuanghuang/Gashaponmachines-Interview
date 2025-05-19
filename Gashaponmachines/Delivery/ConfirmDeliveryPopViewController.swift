class ConfirmDeliveryPopViewController: BaseViewController {

    var style: ConfirmDeliveryStyle

    let quitButton: UIButton = UIButton.whiteBackgroundYellowRoundedButton(title: "换个地方", boldFontSize: 24, titleColor: .new_lightGray)

    let confirmButton: UIButton = UIButton.yellowBackgroundButton(title: "确定", boldFontSize: 24)
    
    let nameLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    let phoneLabel = UILabel.with(textColor: .new_gray, fontSize: 26)
	let addressLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    var addressInfo: DeliveryAddress

    init(style: ConfirmDeliveryStyle, addressInfo: DeliveryAddress) {
        self.style = style
        self.addressInfo = addressInfo
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupInviteSuccessView(addressInfo: DeliveryAddress) {
        self.view.backgroundColor = .clear
        
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(311)
            make.center.equalToSuperview()
        }
        
        let logoIv = UIImageView(image: UIImage(named: "delivery_confirm"))
        contentView.addSubview(logoIv)
        logoIv.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(87)
            make.height.equalTo(50)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "确认收货地址")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.centerX.equalTo(contentView)
        }

        let nameView = UIView.withBackgounrdColor(.new_backgroundColor.alpha(0.3))
        nameView.layer.cornerRadius = 4
        contentView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(42)
        }
        
        nameLabel.text = addressInfo.name
        nameView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }

        phoneLabel.text = addressInfo.phone
        nameView.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        let adressView = UIView.withBackgounrdColor(.new_backgroundColor.alpha(0.3))
        adressView.layer.cornerRadius = 4
        contentView.addSubview(adressView)
        adressView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom).offset(8)
            make.left.right.equalTo(nameView)
        }

        addressLabel.text = addressInfo.address
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .left
        adressView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.bottom.right.equalTo(-12)
        }

        quitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.top.equalTo(adressView.snp.bottom).offset(12)
            make.bottom.equalTo(contentView).offset(-12)
            make.right.equalTo(contentView.snp.centerX).offset(-6)
            make.width.equalTo(137)
            make.height.equalTo(44)
        }

        confirmButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.bottom.size.equalTo(quitButton)
            make.left.equalTo(contentView.snp.centerX).offset(6)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInviteSuccessView(addressInfo: self.addressInfo)
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
