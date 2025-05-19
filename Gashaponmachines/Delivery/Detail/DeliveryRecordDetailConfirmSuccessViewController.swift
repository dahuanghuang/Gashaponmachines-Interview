class DeliveryRecordDetailConfirmSuccessViewController: BaseViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    let icon = UIImageView(image: UIImage(named: "delivery_detail_confirm"))

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView() {
        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        blackView.tag = 440
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.tag = 441
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
        }

        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(20)
            make.size.equalTo(50)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "已确认收货！")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(icon.snp.bottom).offset(20)
        }

        let titleLbl = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "可在 「已收货」中查看详情")
        contentView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(contentView).offset(-20)
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
