import UIKit

//  升级VIP弹窗
class GameNewUpgradeVIPViewController: BaseViewController {

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

        let icon = UIImageView.with(imageName: "game_iap_logo")
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "免费领取VIP啦")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(icon.snp.bottom).offset(20)
        }

        let desLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "您的扭蛋体验次数已用完, 现在花18元开通VIP会员即可获得永久扭蛋体验并赠送您等值元气")
        desLabel.setLineSpacing(lineHeightMultiple: 1.5)
        desLabel.numberOfLines = 0
        desLabel.preferredMaxLayoutWidth = 250
        contentView.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }

        let tipLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 28, defaultText: "*注: VIP是用于驱动扭蛋机的, 元气是将商品放入蛋槽并发货的。不同扭蛋机都是同等的体验，额外支付不等的元气是根据获得扭蛋价值决定的")
        tipLabel.setLineSpacing(lineHeightMultiple: 1.5)
        tipLabel.numberOfLines = 0
        tipLabel.preferredMaxLayoutWidth = 250
        contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(desLabel.snp.bottom).offset(12)
        }

        let confirmButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "升级VIP领元气", fontSize: 28)
        confirmButton.addTarget(self, action: #selector(goToMembershipViewController), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(20)
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
