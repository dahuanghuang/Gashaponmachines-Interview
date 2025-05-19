//enum PopOverViewControllerType {
//    case unknown
//
//    // 蛋壳兑换成功
//    case exchangeSuccess
//    // 蛋壳商城蛋壳不足
//    case mallBalanceNotEnough
//    // 发货蛋壳不足
//    case deliveryBalanceNotEnough
//    // 推送通知
//    case pushNotification
//}
//
//class PopOverViewController: BaseViewController {
//
//    var popType: PopOverViewControllerType = .unknown
//
//    let window = UIApplication.shared.keyWindow!
//
//    lazy var closeButton: UIButton = UIButton.blackTextWhiteBackgroundYellowRoundedButton(title: "先不来了")
//
//    lazy var confirmButton: UIButton = UIButton()
//
//    /// dismiss 后回调
//    var completionClosure: (() -> Void)?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if self.popType	== .mallBalanceNotEnough || self.popType == .deliveryBalanceNotEnough {
//            setupBalanceNotEnough()
//        } else if self.popType == .pushNotification {
//            setupPushNotificationView()
//        } else if self.popType == .exchangeSuccess {
//            setupView()
//        }
//    }
//
//    init(type: PopOverViewControllerType, completionBlock: (() -> Void)? = nil) {
//        super.init(nibName: nil, bundle: nil)
//        self.popType = type
//        self.completionClosure = completionBlock
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    public func showOn(vc: UIViewController) {
//        vc.addChild(self)
//        vc.view.addSubview(self.view)
//    }
//
//    fileprivate func setupPushNotificationView() {
//        self.view.backgroundColor = .clear
//        let blackView = UIView()
//        blackView.backgroundColor = .qu_popBackgroundColor
//        blackView.tag = 440
//
//        self.window.addSubview(blackView)
//        blackView.snp.makeConstraints { make in
//            make.edges.equalTo(self.window)
//        }
//
//        let contentView = UIView()
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 4
//        contentView.layer.masksToBounds = true
//        contentView.tag = 441
//        blackView.addSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.width.equalTo(280)
//            make.center.equalTo(blackView)
//        }
//
//        let icon = UIImageView(image: UIImage(named: "guide_notification"))
//        icon.contentMode = .scaleAspectFit
//        contentView.addSubview(icon)
//        icon.snp.makeConstraints { make in
//            make.centerX.equalTo(contentView)
//            make.left.equalTo(contentView).offset(16)
//            make.right.equalTo(contentView).offset(-16)
//            make.top.equalTo(contentView).offset(24)
//        }
//
//        let titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "为了及时收到扭蛋上新及优惠信息\n 请在下一步选择开启通知")
//        titleLabel.setLineSpacing(lineHeightMultiple: 1.5)
//        titleLabel.numberOfLines = 2
//        titleLabel.textAlignment = .center
//        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(contentView)
//            make.top.equalTo(icon.snp.bottom).offset(16)
//        }
//
//        let buttonWidth = (280 - 12 * 2)
//
//        self.confirmButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "去开启", fontSize: 28)
//        contentView.addSubview(confirmButton)
//        confirmButton.snp.makeConstraints { make in
//            make.height.equalTo(48)
//            make.width.equalTo(buttonWidth)
//            make.centerX.equalTo(contentView)
//            make.top.equalTo(titleLabel.snp.bottom).offset(16)
//            make.bottom.equalTo(contentView).offset(-16)
//        }
//    }
//
//    fileprivate func setupDankeNotEnough() {
//        self.view.backgroundColor = .clear
//        let blackView = UIView()
//        blackView.backgroundColor = .qu_popBackgroundColor
//        blackView.tag = 440
//        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
//
//        self.window.addSubview(blackView)
//        blackView.snp.makeConstraints { make in
//            make.edges.equalTo(self.window)
//        }
//
//        let contentView = UIView()
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 4
//        contentView.layer.masksToBounds = true
//        contentView.tag = 441
//        blackView.addSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.width.equalTo(280)
//            make.center.equalTo(blackView)
//        }
//
//        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "元气不足")
//        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(contentView)
//            make.top.equalTo(contentView).offset(24)
//        }
//
//        let subTitleLabel: UILabel = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "需要补充元气才能发货")
//        contentView.addSubview(subTitleLabel)
//        subTitleLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(contentView)
//            make.top.equalTo(titleLabel.snp.bottom).offset(8)
//        }
//
//        let icon = UIImageView(image: UIImage(named: "delivery_fail_danke"))
//        contentView.addSubview(icon)
//        icon.snp.makeConstraints { make in
//            make.top.equalTo(subTitleLabel.snp.bottom).offset(24)
//            make.size.equalTo(113)
//            make.centerX.equalTo(contentView)
//        }
//
//        let inviteButton = UIButton.whiteTextCyanGreenBackgroundButton(title: "邀请好友获元气")
//        contentView.addSubview(inviteButton)
//        inviteButton.snp.makeConstraints { make in
//            make.top.equalTo(icon.snp.bottom).offset(20)
//            make.width.equalTo(280-24)
//            make.height.equalTo(48)
//            make.centerX.equalTo(contentView)
//        }
//
//        inviteButton.rx.tap
//            .subscribe(onNext: { button in
//                self.dismissVC()
//            })
//            .disposed(by: disposeBag)
//
//        let chargeButton = UIButton.cyanGreenTextWhiteBackgroundButton(title: "+ 补充元气")
//        contentView.addSubview(chargeButton)
//        chargeButton.snp.makeConstraints { make in
//            make.top.equalTo(inviteButton.snp.bottom).offset(12)
//            make.size.equalTo(inviteButton)
//            make.centerX.equalTo(contentView)
//            make.bottom.equalTo(contentView).offset(-16)
//        }
//
//    }
//
//    fileprivate func setupBalanceNotEnough() {
//        self.view.backgroundColor = .clear
//        let blackView = UIView()
//        blackView.backgroundColor = .qu_popBackgroundColor
//        blackView.tag = 440
//        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
//
//        self.window.addSubview(blackView)
//        blackView.snp.makeConstraints { make in
//            make.edges.equalTo(self.window)
//        }
//
//        let contentView = UIView()
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 4
//        contentView.layer.masksToBounds = true
//        contentView.tag = 441
//        blackView.addSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.width.equalTo(280)
//            make.center.equalTo(blackView)
//        }
//
//        let icon = UIImageView(image: UIImage(named: "delivery_fail_danke"))
//        contentView.addSubview(icon)
//        icon.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(20)
//            make.centerX.width.equalTo(contentView)
//            make.height.equalTo(140)
//        }
//
//        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "蛋壳不足")
//        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(icon.snp.bottom)
//            make.centerX.equalTo(contentView)
//        }
//
//        var subTitleLabel: UILabel!
//        if self.popType == .deliveryBalanceNotEnough {
//            subTitleLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "需要换取蛋壳补充")
//        } else if self.popType == .mallBalanceNotEnough {
//            subTitleLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "可前往【蛋槽】兑换蛋壳哦~")
//        }
//        contentView.addSubview(subTitleLabel)
//        subTitleLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(8)
//            make.centerX.equalTo(contentView)
//        }
//
//        var closeButton: UIButton!
//        if self.popType == .deliveryBalanceNotEnough {
//            closeButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "去换蛋壳")
//        } else if self.popType == .mallBalanceNotEnough {
//            closeButton = UIButton.whiteTextRedBackgroundRedRoundedButton(title: "好的")
//        }
//
//        contentView.addSubview(closeButton)
//        closeButton.snp.makeConstraints { make in
//            make.top.equalTo(subTitleLabel.snp.bottom).offset(32)
//            make.left.equalTo(12)
//            make.right.equalTo(-12)
//            make.height.equalTo(48)
//            make.bottom.equalTo(contentView).offset(-16)
//        }
//
//    	closeButton.rx.tap
//            .subscribe(onNext: { button in
//            	self.dismissVC()
//        	})
//            .disposed(by: disposeBag)
//    }
//
//    fileprivate func setupView() {
//        self.view.backgroundColor = .clear
//        let blackView = UIView()
//        blackView.backgroundColor = .qu_popBackgroundColor
//        blackView.tag = 440
//        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
//
//        self.window.addSubview(blackView)
//        blackView.snp.makeConstraints { make in
//            make.edges.equalTo(self.window)
//        }
//
//        let contentView = UIView()
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 4
//        contentView.layer.masksToBounds = true
//        contentView.tag = 441
//        blackView.addSubview(contentView)
//
//        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)
//        titleLabel.text = "换取成功!"
//        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(contentView).offset(16)
//            make.centerX.equalTo(contentView)
//        }
//
//        let icon = UIImageView(image: UIImage(named: "exchange_success"))
//        contentView.addSubview(icon)
//        icon.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(16)
//            make.width.centerX.equalToSuperview()
//            make.height.equalTo(160)
//        }
//
//        self.closeButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "好的")
//        contentView.addSubview(closeButton)
//        closeButton.snp.makeConstraints { make in
//            make.top.equalTo(icon.snp.bottom).offset(16)
//            make.height.equalTo(48)
//            make.width.equalTo(122)
//            make.centerX.equalTo(contentView)
//            make.bottom.equalToSuperview().offset(-12)
//        }
//
//        contentView.snp.makeConstraints { make in
//            make.width.equalTo(280)
//            make.center.equalTo(blackView)
////            make.height.equalTo(300)
//        }
//
//        closeButton.rx.tap
//            .asDriver()
//            .drive(onNext: { [weak self] button in
//            	self?.dismissVC()
//        	})
//        	.disposed(by: disposeBag)
//    }
//
//    @objc fileprivate func dismissVC() {
//        let window = UIApplication.shared.keyWindow
//
//        let black = window?.viewWithTag(440)
//
//        let contentView = window?.viewWithTag(441)
//
//        contentView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
//
//        UIView.animate(withDuration: 0.35, animations: {
//            contentView?.transform = CGAffineTransform.init(scaleX: 1/300, y: 1/270)
//            black?.alpha = 0
//        }, completion: { [weak self] finished in
//            contentView?.removeFromSuperview()
//            black?.removeFromSuperview()
//            self?.willMove(toParent: nil)
//            self?.view.removeFromSuperview()
//            self?.removeFromParent()
//            if let block = self?.completionClosure {
//                block()
//            }
//        })
//    }
//}
