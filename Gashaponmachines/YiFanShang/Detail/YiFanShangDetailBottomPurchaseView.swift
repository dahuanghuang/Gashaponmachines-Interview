import UIKit

/// 底部购买视图
class YiFanShangDetailBottomPurchaseView: UIView {
    /// +号(充值)
    let rechargeButton = UIButton.with(imageName: "yfs_recharge")
    /// 元气值
    let moneyCountLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    /// 立即购买按钮
    let purchaseButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "立即购买", boldFontSize: 32)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    func setupUI() {

        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.white
        self.addShadow(offset: CGSize(width: 0, height: 0), color: .black, radius: 8, opacity: 0.2)

        let topContainer = UIView()
        topContainer.backgroundColor = .white
        addSubview(topContainer)
        topContainer.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44)
        }

        topContainer.addSubview(rechargeButton)
        rechargeButton.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        let moneyLabel = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "我的元气")
        topContainer.addSubview(moneyLabel)
        moneyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rechargeButton)
            make.left.equalTo(rechargeButton.snp.right).offset(8)
        }

        addSubview(moneyCountLabel)
        moneyCountLabel.snp.makeConstraints { make in
            make.left.equalTo(moneyLabel.snp.right).offset(4)
            make.centerY.equalTo(moneyLabel)
        }

        addSubview(purchaseButton)
        purchaseButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.equalTo(topContainer.snp.bottom).offset(8)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
    }

    func configWith(env: YiFanShangDetailEnvelope) {
        if let price = env.price {
            let attrStr = NSMutableAttributedString.init(string: "立即购买", attributes: [.foregroundColor: UIColor.qu_black, .font: UIFont.boldSystemFont(ofSize: 16)])
            let priceAttrStr = NSAttributedString.init(string: "(\(price)元气/次)", attributes: [.foregroundColor: UIColor.qu_black, .font: UIFont.systemFont(ofSize: 12)])
            attrStr.append(priceAttrStr)
            purchaseButton.setAttributedTitle(attrStr, for: .normal)
        }
        moneyCountLabel.text = env.balance
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
