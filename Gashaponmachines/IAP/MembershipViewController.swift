import SnapKit
import UIKit
import SwiftyStoreKit

class MembershipViewController: BaseViewController {

    let viewModel = MembershipViewModel()

    /// 产品ID
    var productId: String?
    /// 票据
    var receipt: String?
    /// 是否会员充值服务器验证成功
    var isVerifySuccess = false

    var timer: Timer?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)

    lazy var detailLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    lazy var bottomLabel = UILabel.with(textColor: UIColor.qu_lightGray, fontSize: 24)

    lazy var desTitleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "详情说明")

    lazy var upgradeButton = MembershipUpgradeButton()

    lazy var avatar = UIImageView()

    lazy var card = UIImageView.with(imageName: "vip_card")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()

        viewModel.viewDidLoadTrigger.onNext(())

        InAppPurchase.shared.delegate = self
    }

    func setupUI() {
        self.navigationItem.title = "会员中心"
        let bg = UIImageView.with(imageName: "vip_black_bg")
        view.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: Constants.kScreenWidth, height: 260/750*Constants.kScreenWidth))
            make.top.centerX.equalToSuperview()
        }

        view.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.size.equalTo(CGSize(width: 598/2, height: 320/2))
            make.centerX.equalToSuperview()
        }

        view.addSubview(desTitleLabel)
        desTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(card.snp.bottom).offset(40)
        }

        let container = UIView()
        card.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        container.addSubview(avatar)
        avatar.layer.cornerRadius = 27.5
        avatar.layer.masksToBounds = true
        avatar.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(55)
        }

        let icon = UIImageView.with(imageName: "vip_icon_gray")
        card.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.bottom.right.equalTo(avatar)
            make.size.equalTo(20)
        }

        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatar.snp.bottom).offset(16)
        }

        container.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        view.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-18)
            make.centerX.equalToSuperview()
        }

        view.addSubview(upgradeButton)
        upgradeButton.snp.makeConstraints { make in
            make.bottom.equalTo(bottomLabel.snp.top).offset(-8)
            make.width.equalTo(280)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

//        self.viewModel.IAPProductId
//            .subscribe(onNext: { [weak self] env in
//                self?.setupUI()
//            })
//            .disposed(by: disposeBag)

        upgradeButton.rx.tap.asObservable()
            .withLatestFrom(self.viewModel.IAPProductId.map { $0.productId })
            .subscribe(onNext: { productId in
                InAppPurchase.shared.purchase(productId: productId)
            })
            .disposed(by: disposeBag)

        self.viewModel.sendReceiptResult
            .subscribe(onNext: { [weak self] _ in
                self?.removeTimer()
                HUD.shared.dismiss()
                HUD.success(second: 2, text: "购买成功", completion: nil)
            })
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.shared.dismiss()
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)

        self.viewModel.memberInfo
            .subscribe(onNext: { info in
                self.avatar.gas_setImageWithURL(info.user?.avatar)

                self.titleLabel.text = info.user?.nickname
                self.bottomLabel.text = info.subNotice

                if let playCount = info.user?.restNonVipPlayCount {
                    let allStr = "再扭蛋 \(playCount) 次，需要升级 VIP"
                    let string = NSMutableAttributedString(string: allStr)
                    string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.qu_orange, NSAttributedString.Key.font: UIFont.withBoldPixel(28)], range: (allStr as NSString).range(of: "\(playCount)"))
                    self.detailLabel.attributedText = string
                }

                if let price = info.price {
                    self.upgradeButton.moneyLabel.text = "¥\(price)"
                }

                if let costNotice = info.notice {
                    self.upgradeButton.label.text = costNotice
                }

                let des = info.description
//                var lastView = self.desTitleLabel
                var lastView: UIView?
                des.forEach { line in
                    if let first = line.first, let second = line.last {
                        let firstLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: first)
                        self.view.addSubview(firstLabel)
                        firstLabel.snp.makeConstraints { make in
                            if let lastView = lastView {
                                make.top.equalTo(lastView.snp.bottom).offset(12)
                            } else {
                                make.top.equalTo(self.desTitleLabel.snp.bottom).offset(12)
                            }
                            make.left.equalTo(self.card)
                        }

                        let attributedString = second.htmlToAttributedString
                        let secondLabel = UILabel.with(textColor: .qu_black, fontSize: 28)
                        secondLabel.attributedText = attributedString
                        secondLabel.numberOfLines = 0
                        secondLabel.preferredMaxLayoutWidth = 565 / 2
                        self.view.addSubview(secondLabel)
                        secondLabel.snp.makeConstraints { make in
                            make.top.equalTo(firstLabel)
                            make.left.equalTo(firstLabel.snp.right).offset(5)
                            make.right.equalTo(self.card)
                        }

                        lastView = firstLabel
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    /// 开启充值验证调度器
    private func addVerifyTimer() {
        let timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(verifyReceipt), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }

    // 关闭定时器
    private func removeTimer() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    @objc func verifyReceipt() {
        if let productId = self.productId, let receipt = self.receipt {
            self.viewModel.sendReceiptTrigger.onNext((productId, receipt))
        }
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                                .characterEncoding: String.Encoding.utf8.rawValue
                                                                ],
                                          documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension MembershipViewController: InAppPurchaseDelegate {
    func willSendReceiptToServer(productId: String, receipt: String, transaction: PaymentTransaction) {
        HUD.shared.persist(text: "正在验证购买... 请稍候")
        self.productId = productId
        self.receipt = receipt
        self.viewModel.sendReceiptTrigger.onNext((productId, receipt))
        addVerifyTimer()
        SwiftyStoreKit.finishTransaction(transaction)
    }
}

class MembershipUpgradeButton: UIButton {

    let moneyLabel = UILabel.with(textColor: UIColor.UIColorFromRGB(0xfd4152), boldFontSize: 34)

    let label = UILabel.with(textColor: .qu_black, boldFontSize: 32)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .qu_yellow
        self.layer.cornerRadius = 48/2
        self.layer.masksToBounds = true

        moneyLabel.textAlignment = .center
        addSubview(moneyLabel)
        moneyLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.left.centerY.equalToSuperview()
        }

        let line = UIView.withBackgounrdColor(UIColor.UIColorFromRGB(0xbc9d07))
        addSubview(line)
        line.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.left.equalToSuperview().offset(90)
            make.centerY.equalToSuperview()
            make.height.equalTo(48 * 2 / 3)
        }

        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(moneyLabel.snp.right)
            make.centerY.right.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
