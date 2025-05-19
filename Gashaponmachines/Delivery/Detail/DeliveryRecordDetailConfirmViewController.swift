class DeliveryRecordDetailConfirmViewController: BaseViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    let quitButton = UIButton.whiteBackgroundYellowRoundedButton(title: "取消", boldFontSize: 24)
    let confirmButton = UIButton.yellowBackgroundButton(title: "是的", boldFontSize: 24)

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView() {
        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.tag = 440
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.tag = 441
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "是否确认收货？")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(28)
        }

        let titleLbl = UILabel.with(textColor: .qu_lightGray, fontSize: 24, defaultText: "确认后将放到 「已收货」页面中")
        contentView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }

        let container = UIView()
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(20)
            make.centerX.equalTo(contentView)
        }

        quitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(28)
            make.width.equalTo(122)
            make.height.equalTo(48)
            make.bottom.equalTo(contentView).offset(-20)
            make.left.equalTo(contentView).offset(12)
        }

        confirmButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.size.equalTo(quitButton)
            make.centerY.equalTo(quitButton)
            make.left.equalTo(quitButton.snp.right).offset(12)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
