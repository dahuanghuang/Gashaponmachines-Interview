class ConfirmDeliveryBalanceNotEnoughViewController: BaseViewController {
    init(unableAffordTips: ShipInfoEnvelope.Tip, isAffordShipByBalance: String) {
        super.init(nibName: nil, bundle: nil)
        setupBalanceNotEnough(unableAffordTips: unableAffordTips, isAffordShipByBalance: isAffordShipByBalance == "1")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupBalanceNotEnough(unableAffordTips: ShipInfoEnvelope.Tip, isAffordShipByBalance: Bool) {
        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.tag = 440
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))

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

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: unableAffordTips.title)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(24)
        }

        let subTitleLabel: UILabel = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: unableAffordTips.subTitle)
        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        let icon = UIImageView(image: UIImage(named: isAffordShipByBalance ? "delivery_fail_balance" : "delivery_fail_danke"))
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(24)
            make.size.equalTo(113)
            make.centerX.equalTo(contentView)
        }

        var topButton: UIButton!
        if !isAffordShipByBalance {
            topButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: unableAffordTips.button1Title)
            contentView.addSubview(topButton)
            topButton.snp.makeConstraints { make in
                make.top.equalTo(icon.snp.bottom).offset(20)
                make.width.equalTo(280-24)
                make.height.equalTo(48)
                make.centerX.equalTo(contentView)
                make.bottom.equalTo(contentView).offset(-16)
            }

            topButton.rx.tap
                .subscribe(onNext: { [weak self] button in
                    self?.dismiss(animated: true) {
                        if let action = unableAffordTips.button1Jump {
                            RouterService.route(to: action)
                        } else {
                            HUD.showError(second: 2, text: "button1Jump 为空", completion: nil)
                        }
                    }
                })
                .disposed(by: disposeBag)
        } else {
            topButton = UIButton.cyanGreenTextWhiteBackgroundButton(title: unableAffordTips.button1Title)
            contentView.addSubview(topButton)
            topButton.snp.makeConstraints { make in
                make.top.equalTo(icon.snp.bottom).offset(20)
                make.width.equalTo(280-24)
                make.height.equalTo(48)
                make.centerX.equalTo(contentView)
            }

            topButton.rx.tap
                .subscribe(onNext: { [weak self] button in
                    self?.dismiss(animated: true) {
                        if let action = unableAffordTips.button1Jump {
                            RouterService.route(to: action)
                        } else {
                            HUD.showError(second: 2, text: "button1Jump 为空", completion: nil)
                        }
                    }
                })
                .disposed(by: disposeBag)

            let bottomButton = UIButton.whiteTextCyanGreenBackgroundButton(title: unableAffordTips.button2Title)
            contentView.addSubview(bottomButton)
            bottomButton.snp.makeConstraints { make in
                make.top.equalTo(topButton.snp.bottom).offset(20)
                make.width.equalTo(280-24)
                make.height.equalTo(48)
                make.centerX.equalTo(contentView)
                make.bottom.equalTo(contentView).offset(-16)
            }

            bottomButton.rx.tap
                .subscribe(onNext: { [weak self] button in
                    self?.dismiss(animated: true) {
                        if let action = unableAffordTips.button2Jump {
                            RouterService.route(to: action)
                        } else {
                            HUD.showError(second: 2, text: "button2Jump 为空", completion: nil)
                        }
                    }
                })
                .disposed(by: disposeBag)

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
