class AboutViewController: BaseViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor
        
        let navBar = CustomNavigationBar()
        navBar.title = "关于我们"
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }

        let icon = UIImageView(image: UIImage(named: "about_logo"))
        icon.layer.cornerRadius = 4
        icon.layer.masksToBounds = true
        self.view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.size.equalTo(80)
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view.safeArea.top).offset(192/2)
        }

        let str = "Version: " + DeviceInfo.getAppVersion() + " Build: " + DeviceInfo.getBuildVersion()
        let label = UILabel.with(textColor: .qu_black, fontSize: 32, defaultText: str)
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(icon.snp.bottom).offset(12)
        }

        let privacyView = UIView.withBackgounrdColor(.white)
        privacyView.layer.cornerRadius = 12
        self.view.addSubview(privacyView)
        privacyView.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(36)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(52)
        }

        let privacyLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "《服务协议》和《隐私政策》")
        privacyLabel.textAlignment = .left
        privacyView.addSubview(privacyLabel)
        privacyLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(8)
        }

        let privacyIv = UIImageView(image: UIImage(named: "profile_privacy"))
        privacyView.addSubview(privacyIv)
        privacyIv.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-8)
            make.width.equalTo(12)
            make.height.equalTo(25)
        }

        let privacyBtn = UIButton()
        privacyBtn.addTarget(self, action: #selector(jumpToPrivacy), for: .touchUpInside)
        privacyView.addSubview(privacyBtn)
        privacyBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @objc func jumpToPrivacy() {
        if let config = AppEnvironment.current.config, let agreementURL = config.siteURLs["userAgreementURL"] {
            RouterService.route(to: agreementURL)
        }
    }
}
