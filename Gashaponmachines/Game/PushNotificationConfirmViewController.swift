class PushNotificationConfirmViewController: BaseViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let confirmButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "好的", fontSize: 28)

    fileprivate func setup() {
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
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.tag = 441
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
        }

        let icon = UIImageView(image: UIImage(named: "guide_confirm"))
        icon.contentMode = .scaleAspectFit
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(contentView).offset(16)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "主人，为了您能收到各种福利消息 \n请在下一步点击『允许』哦")
        titleLabel.setLineSpacing(lineHeightMultiple: 1.5)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(icon.snp.bottom).offset(16)
        }

        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.width.equalTo(122)
           	make.centerX.equalTo(contentView)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(contentView).offset(-16)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
