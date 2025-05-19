import RxDataSources
import RxCocoa
import RxSwift

final class DeliverySuccessViewController: BaseViewController {
    
    lazy var continueButton: UIButton = {
        let title = (self.style == .eggProduct ? "回到蛋槽" : "继续兑换")
        return UIButton.whiteBackgroundYellowRoundedButton(title: title, boldFontSize: 24)
    }()
    
    let detailButton: UIButton = UIButton.yellowBackgroundButton(title: "发货详情", boldFontSize: 24)

    var shipId: String

    var style: ConfirmDeliveryStyle

    init(style: ConfirmDeliveryStyle, shipId: String) {
        self.style = style
        self.shipId = shipId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        let titleLb = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "兑换成功")
        titleLb.textAlignment = .center
        view.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        let topIv = UIImageView(image: UIImage(named: "delivery_success_bg"))
        view.addSubview(topIv)
        topIv.snp.makeConstraints { make in
            make.top.equalTo(titleLb.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(Constants.kScreenWidth * 0.57)
        }
        
        let descLabel = UILabel.with(textColor: UIColor(hex: "A67514")!, fontSize: 20, defaultText: "预计1-5个工作日内发货")
        descLabel.textAlignment = .center
        topIv.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.centerX.equalTo(topIv)
            make.bottom.equalTo(-9)
        }

        let statusLabel = UILabel.with(textColor: UIColor.qu_black, boldFontSize: 28)
        topIv.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(descLabel.snp.top).offset(-2)
        }

        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { make in
            make.top.equalTo(topIv.snp.bottom).offset(12)
            make.left.equalTo(12)
            make.height.equalTo(44)
        }

        view.addSubview(detailButton)
        detailButton.snp.makeConstraints { make in
            make.top.size.equalTo(continueButton)
            make.right.equalTo(-12)
            make.left.equalTo(continueButton.snp.right).offset(10)
        }

        switch self.style {
        case .eggProduct:
            statusLabel.text = "申请发货成功"
        case .mallProduct:
            statusLabel.text = "商品兑换成功"
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.continueButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                if self?.style == .eggProduct {
                    self?.navigationController?.popToRootViewController(animated: true)
                } else {
                    if let viewController = self?.navigationController?.viewControllers.first(where: {$0 is MallDetailViewController}) {
                        self?.navigationController?.popToViewController(viewController, animated: true)
                    }
                }
        	})
        	.disposed(by: disposeBag)

        self.detailButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                if let shipId = self?.shipId {
                    self?.navigationController?.pushViewController(DeliveryRecordDetailViewController(shipId: shipId), animated: true)
                }
        	})
        	.disposed(by: disposeBag)
    }
}
