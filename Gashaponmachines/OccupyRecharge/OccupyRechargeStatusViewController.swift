enum OccupyRechageStatus {
    // 充值成功
    case success
    // 充值成功 但超时
    case timeout
    // 失败(多种情况失败, 不止包含霸充)
    case fail
}

/// 充值结果弹窗(成功, 超时, 失败)
class OccupyRechargeStatusViewController: BaseViewController {

//    private let width: CGFloat = 280

    private let icon = UIImageView()

    private let titleLabel = UILabel.with(textColor: .black, boldFontSize: 32)

//    private lazy var desLabel: UILabel = {
//    	let label = UILabel.with(textColor: .qu_black, fontSize: 24)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.preferredMaxLayoutWidth = width
//        return label
//    }()

    private var tip: String?

    init(status: OccupyRechageStatus, title: String? = nil) {
        super.init(nibName: nil, bundle: nil)

        self.tip = title

        setupView(status: status)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView(status: OccupyRechageStatus) {
        self.view.backgroundColor = .clear
        
        let blackView = UIView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        blackView.addGestureRecognizer(gesture)
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 12
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(279)
            make.height.equalTo(158)
            make.center.equalTo(blackView)
        }

        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(-12)
            make.width.equalToSuperview()
            make.height.equalTo(114)
        }

        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }

        if status == .success {
            icon.image = UIImage(named: "occupy_success")
            titleLabel.text = "霸充成功！"
        } else if status == .timeout {
            icon.image = UIImage(named: "occupy_timeout")
            titleLabel.text = "霸机超时"
        } else if status == .fail {
            icon.image = UIImage(named: "occupy_fail")
            titleLabel.text = self.tip
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delay(3) {
            self.dismissVC()
        }
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
