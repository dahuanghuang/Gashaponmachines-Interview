/// 扭蛋规则弹窗
class GameNewInAppPurchasePopViewController: BaseViewController {

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

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "扭蛋规则")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalToSuperview().offset(24)
        }

        let label1 = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "⦁ 新用户赠送一定次数的免费扭蛋体验，体验结束后需要升级VIP会员可获得解锁全部扭蛋机永久扭蛋资格；")
        label1.numberOfLines = 0
        label1.setLineSpacing(lineHeightMultiple: 1.5)
        contentView.addSubview(label1)
        label1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        let label2 = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "⦁ 元气为用户获得扭蛋商品放入蛋槽发货的费用；")
        label2.numberOfLines = 0
        label2.setLineSpacing(lineHeightMultiple: 1.5)
        contentView.addSubview(label2)
        label2.snp.makeConstraints { make in
            make.top.equalTo(label1.snp.bottom)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        let label3 = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "⦁ 由于扭蛋商品不同，不同机器需要不等的元气；")
        label3.numberOfLines = 0
        label3.setLineSpacing(lineHeightMultiple: 1.5)
        contentView.addSubview(label3)
        label3.snp.makeConstraints { make in
            make.top.equalTo(label2.snp.bottom)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        let label4 = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "⦁ 用户如果不需要放入蛋槽发货，可以使用免元气机台；")
        label4.numberOfLines = 0
        label4.setLineSpacing(lineHeightMultiple: 1.5)
        contentView.addSubview(label4)
        label4.snp.makeConstraints { make in
            make.top.equalTo(label3.snp.bottom)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        let bottomImageView = UIImageView.with(imageName: "game_pop_bottom")
        contentView.addSubview(bottomImageView)
        bottomImageView.snp.makeConstraints { make in
            make.top.equalTo(label4.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 260, height: 80))
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
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
