class GameNewRulePopViewController: BaseViewController {

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
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.tag = 441
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
        }

        let icon = UIImageView.with(imageName: "vip_pop_logo")
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "终于等到您!")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(icon.snp.bottom).offset(20)
        }

        let desLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "谢谢您对元气扭蛋的支持，您现在支付 18 元即可点亮图标获得永久VIP扭蛋资格。我们将立即返回 180 元气到您账号。")
        desLabel.setLineSpacing(lineHeightMultiple: 1.5)
        desLabel.numberOfLines = 0
        desLabel.preferredMaxLayoutWidth = 250
        contentView.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }

        let confirmButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "升级VIP领 180 元气", fontSize: 28)
        confirmButton.addTarget(self, action: #selector(goToMembershipViewController), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(desLabel.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 316/2, height: 48))
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-16)
        }

        let closeButton = UIButton.with(imageName: "vip_close")
        closeButton.addTarget(self, action: #selector(normalDismiss), for: .touchUpInside)
        blackView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(40)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @objc func normalDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func goToMembershipViewController() {
        self.dismiss(animated: true) {
            if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {
                if let top = root.selectedViewController?.topMostViewController as? NavigationController {
                    top.pushViewController(MembershipViewController(), animated: true)
                }
            }
        }
    }
}
