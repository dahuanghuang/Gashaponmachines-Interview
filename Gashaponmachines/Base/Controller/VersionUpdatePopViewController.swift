import UIKit

class VersionUpdatePopViewController: UIViewController {

    var cancelClickHandle: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    fileprivate func setupView() {
        self.view.backgroundColor = .clear

        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
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

        let rocketIv = UIImageView(image: UIImage(named: "version_rocket"))
        contentView.addSubview(rocketIv)
        rocketIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(120)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "元气扭蛋邀请你更新新版本")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(rocketIv.snp.bottom).offset(8)
            make.centerX.equalTo(contentView)
        }

        let version = AppEnvironment.current.config?.latestVersion
        let versionLabelW = version?.widthOfString(usingFont: UIFont.systemFont(ofSize: 12))
        let versionLabel = UILabel.with(textColor: .white, fontSize: 24, defaultText: version)
        versionLabel.textAlignment = .center
        versionLabel.layer.cornerRadius = 8
        versionLabel.layer.masksToBounds = true
        versionLabel.backgroundColor = UIColor(hex: "32cf9d")
        contentView.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalTo(contentView)
            if let w = versionLabelW {
                make.width.equalTo(w + 16)
            }
            make.height.equalTo(16)
        }

        // 描述信息
        let desc = AppEnvironment.current.config?.updateDescription
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attrStr = NSMutableAttributedString(string: desc ?? "", attributes: [.paragraphStyle: paragraphStyle])
        let descLabel = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: desc)
        descLabel.numberOfLines = 0
        descLabel.attributedText = attrStr
        contentView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(versionLabel.snp.bottom).offset(24)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }

        let cancelButton = UIButton.blackTextWhiteBackgroundYellowRoundedButton(title: "暂不升级")
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(24)
            make.left.equalTo(12)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-12)
        }

        let confirmButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "立即体验")
        confirmButton.addTarget(self, action: #selector(jumpToAppStore), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.height.width.equalTo(cancelButton)
            make.right.equalTo(-12)
            make.left.equalTo(cancelButton.snp.right).offset(12)
        }
    }

    @objc func cancel() {
        if let handle = cancelClickHandle {
            handle()
        }
        self.dismiss(animated: true, completion: nil)
    }

    @objc func jumpToAppStore() {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id1330946918")!
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
        if let handle = cancelClickHandle {
            handle()
        }
        self.dismiss(animated: true, completion: nil)
    }

}
