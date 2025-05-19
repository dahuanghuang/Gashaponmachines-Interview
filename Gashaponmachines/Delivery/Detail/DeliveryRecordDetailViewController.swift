import UIKit
import RxSwift
import RxCocoa

class DeliveryRecordDetailViewController: BaseViewController {
    
    var viewModel: DeliveryRecordDetailViewModel!
    
    /// 发货状态
    lazy var statusLabel: UILabel = {
        let lb = UILabel.with(textColor: .black, boldFontSize: 48)
        lb.textAlignment = .left
        return lb
    }()
    /// 滚动视图
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .new_backgroundColor
        view.showsVerticalScrollIndicator = false
        view.delaysContentTouches = false
        return view
    }()
    /// 滚动包裹视图
    lazy var wrapperView = UIView.withBackgounrdColor(.new_backgroundColor)
    /// 顶部快递视图
    let expressView = DeliveryRecordDetailExpressView()
    /// 顶部地址视图
    let addressView = DeliveryRecordDetailAddressView()
    
    var lastView: UIView!
    
    init(shipId: String) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = DeliveryRecordDetailViewModel(shipId: shipId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.viewModel.refreshTrigger.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setupUI() {
        view.backgroundColor = .new_backgroundColor
        
        let bgIv = UIImageView(image: UIImage(named: "delivery_detail_bg"))
        view.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(144)
        }
        
        let navBar = CustomNavigationBar()
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        navBar.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(52)
            make.bottom.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(12)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(self.view.safeArea.bottom)
        }

        scrollView.addSubview(wrapperView)
        wrapperView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        wrapperView.addSubview(expressView)
        expressView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(52)
            make.left.right.equalTo(wrapperView)
        }

        wrapperView.addSubview(addressView)
        addressView.snp.makeConstraints { make in
            make.top.equalTo(expressView.snp.bottom)
            make.left.right.equalTo(wrapperView)
        }
        
        let leftCornerView = RoundedCornerView(corners: .allCorners, radius: 6, backgroundColor: .new_backgroundColor)
        wrapperView.addSubview(leftCornerView)
        leftCornerView.snp.makeConstraints { make in
            make.centerX.equalTo(expressView.snp.left)
            make.centerY.equalTo(expressView.snp.bottom)
            make.size.equalTo(12)
        }
        
        let rightCornerView = RoundedCornerView(corners: .allCorners, radius: 6, backgroundColor: .new_backgroundColor)
        wrapperView.addSubview(rightCornerView)
        rightCornerView.snp.makeConstraints { make in
            make.centerX.equalTo(expressView.snp.right)
            make.centerY.equalTo(expressView.snp.bottom)
            make.size.equalTo(12)
        }
        
        let lineIv = UIImageView(image: UIImage(named: "delivery_line"))
        wrapperView.addSubview(lineIv)
        lineIv.snp.makeConstraints { make in
            make.left.equalTo(leftCornerView.snp.right)
            make.right.equalTo(rightCornerView.snp.left)
            make.centerY.equalTo(leftCornerView)
        }

        lastView = addressView
    }

    func setupViewByEnvelope(envelope: ShipDetailEnvelope) {
        self.statusLabel.text = envelope.shipmentTitle
        self.expressView.config(envelope: envelope)
        self.addressView.config(address: envelope.address)

        // 商品
        for (index, product) in envelope.products.enumerated() {
            let view = DeliveryRecordDetailProductView(product: product, isFirst: index == 0, isLast: index == envelope.products.count-1, isCyberInfo: envelope.cyberInfo != nil)
            wrapperView.addSubview(view)
            view.snp.makeConstraints { make in
                make.left.right.equalTo(wrapperView)
                if index == 0 {
                    make.top.equalTo(lastView.snp.bottom).offset(12)
                } else {
                    make.top.equalTo(lastView.snp.bottom)
                }
                make.height.equalTo(104)
            }
            lastView = view
        }

        // 卡号卡密
        if let cyberInfos = envelope.cyberInfo {
        
            let copyAllView = DeliveryRecordDetailCopyAllView(cyberInfos: cyberInfos)
            wrapperView.addSubview(copyAllView)
            copyAllView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(lastView.snp.bottom)
                make.height.equalTo(48)
            }
            lastView = copyAllView
            
            let leftCornerView = RoundedCornerView(corners: .allCorners, radius: 6, backgroundColor: .new_backgroundColor)
            wrapperView.addSubview(leftCornerView)
            leftCornerView.snp.makeConstraints { make in
                make.centerX.equalTo(lastView.snp.left)
                make.centerY.equalTo(lastView.snp.top)
                make.size.equalTo(12)
            }
            
            let rightCornerView = RoundedCornerView(corners: .allCorners, radius: 6, backgroundColor: .new_backgroundColor)
            wrapperView.addSubview(rightCornerView)
            rightCornerView.snp.makeConstraints { make in
                make.centerX.equalTo(lastView.snp.right)
                make.centerY.equalTo(lastView.snp.top)
                make.size.equalTo(12)
            }
            
            let lineIv = UIImageView(image: UIImage(named: "delivery_line"))
            wrapperView.addSubview(lineIv)
            lineIv.snp.makeConstraints { make in
                make.left.equalTo(leftCornerView.snp.right)
                make.right.equalTo(rightCornerView.snp.left)
                make.centerY.equalTo(leftCornerView)
            }
            
            let line = UIView.withBackgounrdColor(.white)
            wrapperView.addSubview(line)
            line.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(8)
            }
            lastView = line
            
            for (index, info) in cyberInfos.enumerated() {
                var height = 0
                if info.cardCodeText != nil { height += 40 }
                if info.cardPwText != nil { height += 40 }
                if info.cardNoText != nil { height += 40 }

                let cardInfoView = DeliveryRecordDetailCardInfoView(cyberInfo: info, isLast: index == cyberInfos.count-1)
                wrapperView.addSubview(cardInfoView)
                cardInfoView.snp.makeConstraints { make in
                    make.top.equalTo(lastView.snp.bottom)
                    make.left.right.equalToSuperview()
                    if index == cyberInfos.count-1 {
                        make.height.equalTo(height+8)
                    }else {
                        make.height.equalTo(height+12)
                    }
                }
                lastView = cardInfoView
            }
        }

        // 使用说明
        if let usage = envelope.usage {
            let usageView = DeliveryRecordDetailUsageView(usage: usage)
            wrapperView.addSubview(usageView)
            usageView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(12)
                make.left.right.equalTo(wrapperView)
            }

            lastView = usageView
        }

        // 发货信息
        let infoView = DeliveryRecordDetailInfoView(envelope: envelope)
        wrapperView.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(12)
            make.left.right.equalTo(wrapperView)
            make.height.equalTo(164)
            make.bottom.equalToSuperview()
        }

        // 确认收货按钮
        if envelope.status == .delivered {
            let buttonView = SingleButtonBottomView(title: "确认收货")
            buttonView.rx.buttonTap
                .asDriver()
                .drive(onNext: { [weak self] in

                    guard let strongself = self else { return }

                    let vc = DeliveryRecordDetailConfirmViewController()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    strongself.navigationController?.present(vc, animated: true, completion: nil)

                    vc.confirmButton.rx.tap
                        .asDriver()
                        .drive(strongself.viewModel.submitSignal)
                    	.disposed(by: vc.disposeBag)
                })
                .disposed(by: disposeBag)

            self.view.addSubview(buttonView)
            buttonView.snp.makeConstraints { make in
                make.left.right.equalTo(self.view)
                make.height.equalTo(60+Constants.kScreenBottomInset)
                make.bottom.equalToSuperview()
            }

            scrollView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeArea.bottom).offset(-72)
            }
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel.shipDetail
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] envelope in
        	    self?.setupViewByEnvelope(envelope: envelope)
        	})
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
            	HUD.showErrorEnvelope(env: env)
        	})
        	.disposed(by: disposeBag)

        self.viewModel.confirmReceive
        	.asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] _ in
                let vc = DeliveryRecordDetailConfirmSuccessViewController()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self?.navigationController?.present(vc, animated: true, completion: nil)
            })
        	.disposed(by: disposeBag)
    }
}
