import RxDataSources
import RxCocoa
import RxSwift

private let ConfirmDeliveryTableViewCellReusableIdentifier = "ConfirmDeliveryTableViewCellReusableIdentifier"

enum ConfirmDeliveryStyle {
    // 蛋壳确认发货
    case eggProduct
    // 商品确认发货
    case mallProduct
}

class ConfirmDeliveryViewController: UIViewController {

    /// 商品价值
    var worth: Int
    /// 商品数量
    var count: Int

    // 商城兑换确认
    init(style: ConfirmDeliveryStyle, mallProductId: String, worth: Int, count: Int) {
        self.style = style
        self.worth = worth
        self.count = count
        self.viewModel = ConfirmDeliveryViewModel(orderIds: nil, mallProductId: mallProductId, keys: nil, buyCount: count)
        super.init(nibName: nil, bundle: nil)
    }

    // 发货确认
    init(style: ConfirmDeliveryStyle, orderIds: [String], collectionIds: [String]) {
        self.style = style
        self.worth = 0
        self.count = 0
        self.viewModel = ConfirmDeliveryViewModel(orderIds: orderIds, mallProductId: nil, keys: collectionIds, buyCount: nil)
        super.init(nibName: nil, bundle: nil)
    }

    var style: ConfirmDeliveryStyle

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let headerView = ConfirmDeliveryAddressHeaderView()

    let footerView = ConfirmDeliveryAddressFooterView()

    var viewModel: ConfirmDeliveryViewModel!

    lazy var bottomToolbar: DeliveryBottomToolbar = {
        switch self.style {
        case .eggProduct:
            return DeliveryBottomToolbar(style: .eggProductConfirm)
        case .mallProduct:
            return DeliveryBottomToolbar(style: .mallProductConfirm)
        }
    }()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.register(ConfirmDeliveryTableViewCell.self, forCellReuseIdentifier: ConfirmDeliveryTableViewCellReusableIdentifier)
        return tv
    }()

    /// 选中的优惠券
    private var selectCoupon: Coupon?
    
    let disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        bindViewModels()
        
        self.viewModel.viewDidLoadTrigger.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.tableView.reloadData()
    }
    
    func setupUI() {
        
        self.view.backgroundColor = .white
        
        let navBar = CustomNavigationBar()
        navBar.title = "确认订单"
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        view.addSubview(bottomToolbar)
        bottomToolbar.snp.makeConstraints { make in
            make.height.equalTo(60+Constants.kScreenBottomInset)
            make.left.right.equalTo(self.view)
            make.bottom.equalToSuperview()
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(bottomToolbar.snp.top)
        }
    }

    // 改变页面优惠券状态
    private func changeCouponState(env: ShipInfoEnvelope) {
        // 底部减扣金额
        let value = self.style == .mallProduct ? (self.worth * self.count) : (Int(env.expressFeeAmount ?? "0") ?? 0 )
        self.bottomToolbar.config(style: self.style, value: value, coupon: self.selectCoupon)

        // 优惠券使用状态
        self.footerView.changeCouponValue(coupon: self.selectCoupon, couponCount: env.availCoupons?.count ?? 0)
    }
    
    var products = [ShipInfoEnvelope.ShipProduct]()

    func bindViewModels() {

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.products
            .drive(self.tableView.rx.items(cellIdentifier: ConfirmDeliveryTableViewCellReusableIdentifier, cellType: ConfirmDeliveryTableViewCell.self)) { (index, item, cell) in
                let isFirst = (index == 0)
                let isLast = (index == self.products.count-1)
                cell.configureWith(product: item, style: self.style, worth: self.worth, count: self.count, isFirst: isFirst, isLast: isLast)
            }
            .disposed(by: disposeBag)

        self.viewModel.envelope.asObservable()
            .subscribe(onNext: { [weak self] env in
                guard let self = self else { return }

                self.products = env.products
                
                self.selectCoupon = env.availCoupons?.first

                self.changeCouponState(env: env)

                self.footerView.configure(env: env, style: self.style, count: self.count)
            })
            .disposed(by: disposeBag)

        self.viewModel.addressInfo
            .drive(onNext: { address in
            	self.headerView.configure(address: address)
                self.tableView.reloadData()
        	})
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
        	})
        	.disposed(by: disposeBag)

        // 提交发货结果
        self.viewModel.submitResult.drive(onNext: { env in
            if env.code == String(GashaponmachinesError.success.rawValue) {
                if let shipId = env.shipId {
                    self.navigationController?.pushViewController(DeliverySuccessViewController(style: self.style, shipId: shipId), animated: true)
                } else {
                    HUD.showError(second: 2, text: "无法找到订单编号，请咨询客服", completion: nil)
                }
            } else {
                HUD.showError(second: 2, text: "发货错误, 错误原因：\(env.msg)", completion: nil)
            }
        })
        .disposed(by: disposeBag)

        // 确认发货点击
        self.bottomToolbar.nextButton.rx.tap
            .asDriver()
            .withLatestFrom(
                Driver.combineLatest(
                    self.viewModel.addressInfo,
                    self.viewModel.envelope.map { $0.freeShipTitle }
                )
            )
            .drive(onNext: { pair in

                guard let address = pair.0 else {
                    HUD.showError(second: 2, text: "请选择收货地址", completion: nil)
                    return
                }

                let vc = ConfirmDeliveryPopViewController(style: self.style, addressInfo: address)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.confirmButton.rx.tap.asDriver()
                    .drive(onNext: { _ in
                        // 刷新蛋槽
                        NotificationCenter.default.post(name: .refreshEggProduct, object: nil)
                        self.viewModel.selectedCoupon.onNext(self.selectCoupon)
                        self.viewModel.confirmDeliverButtonTap.onNext(())
                    })
                	.disposed(by: vc.disposeBag)
                self.navigationController?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        // 地址修改
        self.headerView.addButton.rx.tap
            .asDriver()
            .withLatestFrom(self.viewModel.addressInfo)
            .drive(onNext: { [weak self] addressInfo in
                let vc = AddressListViewController()
                vc.tableView.rx.modelSelected(DeliveryAddress.self)
                    .asDriver()
                    .drive(onNext: { [weak self] address in
                        self?.viewModel.selectedAddress.onNext(address)
                        self?.navigationController?.popViewController(animated: true)
                    })
                    .disposed(by: vc.disposeBag)
                self?.navigationController?.pushViewController(vc, animated: true)
        	})
        	.disposed(by: disposeBag)

        // 优惠券选择
        self.footerView.couponButton.rx.tap
            .asDriver()
            .withLatestFrom((self.viewModel.envelope))
            .drive(onNext: { [weak self] env in
                guard let self = self else { return }

                let vc = CouponSelectPopViewController(availCoupons: env.availCoupons ?? [], allCoupons: env.allCoupons ?? [], selectCoupon: self.selectCoupon)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.navigationController?.present(vc, animated: true, completion: nil)

                vc.selectCouponHandle = { coupon in
                    self.selectCoupon = coupon
                    self.changeCouponState(env: env)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension ConfirmDeliveryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerView.calculateHeight()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerView.calculateHeight()
    }
}
