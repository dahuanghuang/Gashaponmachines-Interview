import RxCocoa
import RxSwift

class CompositionDetailPopViewController: BaseViewController {

    let titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 3
        btn.layer.borderColor = UIColor(hex: "ffe6ac")?.cgColor
        btn.layer.borderWidth = 1
        btn.setTitle("关闭弹窗", for: .normal)
        btn.setTitleColor(.qu_black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()

    lazy var findButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 3
        btn.backgroundColor = UIColor(hex: "ff7645")
        btn.setTitle("前往寻找材料", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()

    var notice: String!

    var action: String!

    init(notice: String, action: String) {
        super.init(nibName: nil, bundle: nil)
        self.notice = notice
        self.action = action
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView() {
        self.view.backgroundColor = .clear

        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentViewH = 112 + notice.heightWithString(fontSize: 14, width: 256)
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.equalTo(contentViewH)
            make.width.equalTo(280)
            make.center.equalTo(blackView)
        }

        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.bottom.equalTo(-16)
            make.height.equalTo(48)
        }

        findButton.addTarget(self, action: #selector(routeToVc), for: .touchUpInside)
        contentView.addSubview(findButton)
        findButton.snp.makeConstraints { (make) in
            make.right.equalTo(-12)
            make.bottom.width.height.equalTo(closeButton)
            make.left.equalTo(closeButton.snp.right).offset(12)
        }

        titleLabel.numberOfLines = 0
        titleLabel.text = notice
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(24)
            make.centerX.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func routeToVc() {
        dismissVC()
        RouterService.route(to: self.action)
    }
}

// class CompositionDetailPopViewController: BaseViewController {
//
//    static let userDefaultPopConfirmKey = "userDefaultPopConfirmKey"
//
//    let quitButton = UIButton.cyanblueTextWhiteBackgroundCyanBlueRoundedButton(title: "取消")
//    let lockButton = UIButton.cyanblueTextWhiteBackgroundCyanBlueRoundedButton(title: "锁定")
//    let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)
//    let desLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 28)
//    let tipLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 24)
//
//    lazy var checkButton: UIButton = {
//        let btn = UIButton(type: .custom)
//        btn.setImage(UIImage(named: "compo_detail_lock_notifi_un"), for: .normal)
//        return btn
//    }()
//
//    fileprivate func setupView() {
//        self.view.backgroundColor = .clear
//        let blackView = UIView()
//        blackView.backgroundColor = .qu_popBackgroundColor
//        blackView.tag = 440
//        self.view.addSubview(blackView)
//        blackView.snp.makeConstraints { make in
//            make.edges.equalTo(self.view)
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
//        titleLabel.text = "是否锁定材料？"
//        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(28)
//            make.centerX.equalToSuperview()
//        }
//
//        desLabel.text = "锁定材料后不能撤销哦～"
//        contentView.addSubview(desLabel)
//        desLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(titleLabel.snp.bottom).offset(8)
//        }
//
//        let container = UIView()
//        contentView.addSubview(container)
//        container.snp.makeConstraints { make in
//            make.top.equalTo(desLabel.snp.bottom).offset(20)
//            make.centerX.equalTo(contentView)
//            make.height.greaterThanOrEqualTo(20)
//        }
//
//        tipLabel.text = "不再提醒"
//        container.addSubview(tipLabel)
//        tipLabel.snp.makeConstraints { make in
//            make.right.centerY.equalTo(container)
//
//        }
//
//        container.addSubview(checkButton)
//        checkButton.snp.makeConstraints { make in
//            make.centerY.equalTo(tipLabel)
//            make.right.equalTo(tipLabel.snp.left).offset(-4)
//            make.size.equalTo(20)
//            make.left.equalTo(container)
//        }
//
//        contentView.addSubview(lockButton)
//        lockButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
//        lockButton.snp.makeConstraints { make in
//            make.top.equalTo(tipLabel.snp.bottom).offset(20)
//            make.width.equalTo(122)
//            make.height.equalTo(48)
//            make.bottom.equalTo(contentView).offset(-12)
//            make.left.equalTo(contentView).offset(12)
//        }
//
//        quitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
//        contentView.addSubview(quitButton)
//        quitButton.snp.makeConstraints { make in
//            make.size.equalTo(lockButton)
//            make.centerY.equalTo(lockButton)
//            make.left.equalTo(lockButton.snp.right).offset(12)
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//
//        checkButton.rx.tap
//            .asDriver()
//            .do(onNext: { [weak self] in
//                if let strongself = self {
//                    strongself.checkButton.isSelected = !strongself.checkButton.isSelected
//                }
//            })
//            .drive(onNext: { [weak self] _ in
//                if let strongself = self {
//                    strongself.checkButton.setImage(strongself.checkButton.isSelected ? UIImage(named: "compo_detail_lock_notifi") : UIImage(named: "compo_detail_lock_notifi_un"), for: .normal)
//                    if strongself.checkButton.isSelected {
//                        AppEnvironment.userDefault.set(true, forKey: CompositionDetailPopViewController.userDefaultPopConfirmKey)
//                        AppEnvironment.userDefault.synchronize()
//                    }
//                }
//            })
//            .disposed(by: disposeBag)
//    }
//
//    @objc func dismissVC() {
//        self.dismiss(animated: true, completion: nil)
//    }
// }
