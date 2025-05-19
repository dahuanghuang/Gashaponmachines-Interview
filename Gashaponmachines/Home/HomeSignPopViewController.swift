import UIKit

class HomeSignPopViewController: BaseViewController {

    let viewModel = HomeSignViewModel()

    /// 显示优惠券列表
    var showCouponHandle: (([PopMenuSignCoupon]) -> Void)?

    var signInfo: PopMenuSignInfo!

    init(signInfo: PopMenuSignInfo) {
        super.init(nibName: nil, bundle: nil)
        self.signInfo = signInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = .clear

        guard let mainInfo = signInfo.mainInfo else {
            return
        }

        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let contentView = UIView.withBackgounrdColor(.clear)
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(297)
            make.height.equalTo(293)
        }

        let topIv = UIImageView(image: UIImage(named: "home_sign_top"))
        contentView.addSubview(topIv)
        topIv.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        // 头部标题
        let titleIv = UIImageView(image: UIImage(named: "home_sign_title"))
        contentView.addSubview(titleIv)
        titleIv.snp.makeConstraints { (make) in
            make.top.equalTo(topIv.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(36)
        }

        let titleLabel = UILabel.with(textColor: UIColor(hex: "ffd9b0")!, fontSize: 24, defaultText: mainInfo.header)
        titleIv.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        // 中间优惠信息
        let centerBgIv = UIImageView(image: UIImage(named: "home_sign_center"))
        contentView.addSubview(centerBgIv)
        centerBgIv.snp.makeConstraints { (make) in
            make.top.equalTo(titleIv.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(132)
        }

        let centerIv = UIImageView()
        centerIv.gas_setImageWithURL(mainInfo.icon)
        centerBgIv.addSubview(centerIv)
        centerIv.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-7)
            make.width.equalTo(60)
            make.height.equalTo(45)
        }

        let centerLabel = UILabel.with(textColor: UIColor(hex: "ffd9b0")!, fontSize: 24, defaultText: mainInfo.title)
        centerLabel.textAlignment = .center
        centerLabel.backgroundColor = UIColor(hex: "6d6d6d")
        centerBgIv.addSubview(centerLabel)
        centerLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(centerIv.snp.bottom)
            make.height.equalTo(15)
            make.width.equalTo(centerIv)
        }

        // 签到按钮
        let actionBgIv = UIImageView(image: UIImage(named: "home_sign_action"))
        actionBgIv.isUserInteractionEnabled = true
        contentView.addSubview(actionBgIv)
        actionBgIv.snp.makeConstraints { (make) in
            make.top.equalTo(centerBgIv.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(36)
        }

        let actionButton = UIButton()
        actionButton.backgroundColor = .clear
        actionButton.addTarget(self, action: #selector(actionButtonClick), for: .touchUpInside)
        actionBgIv.addSubview(actionButton)
        actionButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        // 底部描述
        let bottomIv = UIImageView(image: UIImage(named: "home_sign_bottom"))
        contentView.addSubview(bottomIv)
        bottomIv.snp.makeConstraints { (make) in
            make.top.equalTo(actionBgIv.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(39)
        }

        let bottomLabel = UILabel.with(textColor: UIColor(hex: "ffd9b0")!, fontSize: 24, defaultText: mainInfo.bottom)
        bottomIv.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        // 关闭按钮
        let closeIv = UIImageView(image: UIImage(named: "home_sign_close"))
        closeIv.isUserInteractionEnabled = true
        blackView.addSubview(closeIv)
        closeIv.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(40)
        }

        let closeButton = UIButton()
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(closeButtonClick), for: .touchUpInside)
        closeIv.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @objc func actionButtonClick() {
        if let coupons = self.signInfo.mainInfo?.coupons, !coupons.isEmpty {
            dismiss(animated: true) {
                if let handle = self.showCouponHandle {
                    handle(coupons)
                }
            }
        } else {
            self.viewModel.requestSignIn.onNext(nil)
        }
    }

    @objc func closeButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }

    func dismissVc() {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .HomeSignInSuccess, object: nil)
        })
    }

    override func bindViewModels() {
        viewModel.signInResult
            .subscribe(onNext: { [weak self]_ in
                self?.dismissVc()
            }).disposed(by: disposeBag)

        viewModel.error
            .subscribe(onNext: { _ in
                HUD.showError(second: 2.0, text: "网络错误, 签到失败", completion: nil)
            })
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
