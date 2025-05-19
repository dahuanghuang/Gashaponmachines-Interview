class ExchangeConfrimViewController: BaseViewController {

//    let quitButton = UIButton.blackTextWhiteBackgroundYellowRoundedButton(title: "犹豫一下")
    let quitButton = UIButton.whiteBackgroundYellowRoundedButton(title: "犹豫一下", boldFontSize: 28)

//    let exchangeButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "立即兑换")
    let exchangeButton = UIButton.yellowBackgroundButton(title: "立即兑换", boldFontSize: 28)
    

    init(info: ExchangeInfo) {
        super.init(nibName: nil, bundle: nil)
        setupExchangeConfirmView(info: info)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupExchangeConfirmView(info: ExchangeInfo) {
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
            make.height.equalTo(152)
        }

        let titleLabel = UILabel.with(textColor: .black, boldFontSize: 28, defaultText: "换取蛋壳")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(16)
        }

        let allStr = "确定将 \(info.totalCount) 个扭蛋换成 \(info.totalValue) 蛋壳吗？"
        let string = NSMutableAttributedString(string: allStr)
        string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.new_orange], range: (allStr as NSString).range(of: "\(info.totalCount)"))
        string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.new_orange], range: (allStr as NSString).range(of: "\(info.totalValue)"))

        let contentLabel = UILabel.with(textColor: .new_gray, fontSize: 28)
        contentLabel.attributedText = string
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
        	make.centerX.equalTo(contentView)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        contentView.addSubview(quitButton)
        quitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        quitButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(24)
            make.width.equalTo(122)
            make.height.equalTo(48)
            make.left.equalTo(contentView).offset(12)
            make.bottom.equalTo(contentView).offset(-12)
        }

        contentView.addSubview(exchangeButton)
        exchangeButton.snp.makeConstraints { make in
            make.size.centerY.equalTo(quitButton)
            make.right.equalTo(contentView).offset(-12)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
