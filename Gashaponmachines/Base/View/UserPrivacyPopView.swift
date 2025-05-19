import UIKit

//  用户隐私弹窗
class UserPrivacyPopView: UIView {

    var lookPrivacyHandle: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    func setupUI() {
        self.backgroundColor = .clear

        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "欢迎使用元气扭蛋")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.centerX.equalTo(contentView)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attrStr = NSMutableAttributedString(string: "欢迎使用元气扭蛋，请你在使用前务必仔细阅读并充分理解《服务协议及隐私条约》内容。为了你能顺利使用扭蛋，我们会使用储存权限及手机权限用于储存图片缓存及识别手机设备保障账号安全。你可以阅读完整版", attributes: [.paragraphStyle: paragraphStyle])
        let link = NSAttributedString(string: "《服务协议及隐私条约》", attributes: [.foregroundColor: UIColor(hex: "ffa336")!])
        attrStr.append(link)
        attrStr.append(NSAttributedString(string: "了解详细信息。"))

        let subTitleLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "")
        subTitleLabel.numberOfLines = 0
        subTitleLabel.attributedText = attrStr
        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalTo(24)
            make.right.equalTo(-24)
        }

        let confirmButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: " 我知道了")
        confirmButton.addTarget(self, action: #selector(normalDismiss), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(158)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }

        let linkButton = UIButton()
        linkButton.backgroundColor = .clear
        linkButton.addTarget(self, action: #selector(jumpToPrivacyVc), for: .touchUpInside)
        contentView.addSubview(linkButton)
        linkButton.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(subTitleLabel)
            make.height.equalTo(subTitleLabel).multipliedBy(0.25)
        }
    }

    @objc func normalDismiss() {
        MobSDK.uploadPrivacyPermissionStatus(true, onResult: nil)
        self.isHidden = true
        self.removeFromSuperview()
    }

    @objc func jumpToPrivacyVc() {
        if let handle = lookPrivacyHandle {
            handle()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
