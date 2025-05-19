import RxDataSources
import RxSwift
import RxCocoa

private let RechargeFromCellReuseIdentifier = "RechargeFromCellReuseIdentifier"
private let RechargeOptionCellReuseIdentifier = "RechargeOptionCellReuseIdentifier"

class RechargeViewController: BaseViewController {

    weak var delegate: Rechargable?

    private static let maxRetryQueryCount: Int = 5

    init(isOpenFromGameView: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.isOpenFromGameView = isOpenFromGameView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isOpenFromGameView: Bool = false

    var rechargeFromView: RechargeFromFooterView!

    var viewModel: RechargeViewModel!

    var dataSources: RxTableViewSectionedReloadDataSource<RechargeSectionModel>!

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.layer.cornerRadius = 4
        tv.layer.masksToBounds = true
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tv.register(RechargeOptionCell.self, forCellReuseIdentifier: RechargeOptionCellReuseIdentifier)
        return tv
    }()

    var rechargeButton: UIButton = {
        let rechargeButton = UIButton()

        let totalStr = "+ 充值"
        let string = NSMutableAttributedString(string: totalStr, attributes: [
            NSAttributedString.Key.font: UIFont.withBoldPixel(32),
            NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        let range = totalStr.range(of: "+")!
        let nsRange = NSRange(range, in: totalStr)
        string.addAttributes([NSAttributedString.Key.font: UIFont.withBoldPixel(40)], range: nsRange)
        rechargeButton.setAttributedTitle(string, for: .normal)
        rechargeButton.layer.cornerRadius = 4
        rechargeButton.layer.masksToBounds = true
        rechargeButton.setBackgroundColor(color: .qu_cyanGreen, forUIControlState: .normal)
        return rechargeButton
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.barTintColor = .qu_black
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.updateNavigationTitleColor(.white)

        viewModel.viewWillAppearTrigger.onNext(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DanmakuService.shared.showAlert(type: .Recharge)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        WXApiManager.shared.delegate = self
        AlipayApiManager.shared.delegate = self
        DanmakuService.shared.alertDelegate = self

        self.view.backgroundColor = .white
        self.navigationItem.title = "\(AppEnvironment.reviewKeyWord)充值"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.barButtonItemWith(text: "明细", target: self, selector: #selector(goToRechargeRecord))

        let bottomView = UIView.withBackgounrdColor(.white)
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.height.equalTo(49+12+12)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view.safeArea.bottom)
        }

        bottomView.addSubview(rechargeButton)
        rechargeButton.snp.makeConstraints { make in
            make.center.equalTo(bottomView)
            make.width.equalTo(Constants.kScreenWidth - 24)
            make.height.equalTo(49)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(bottomView.snp.top)
        }

    }

    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel = RechargeViewModel(rechargeButtonTap: self.rechargeButton.rx.tap.asSignal())

        self.dataSources = RxTableViewSectionedReloadDataSource<RechargeSectionModel>(
            configureCell: { [weak self] (ds, tv, ip, _) in
                switch ds[ip] {
                case let .optionSectionItem(balance, options):
                    guard let strongself = self else { return RechargeOptionCell() }
                    let cell: RechargeOptionCell = tv.dequeueReusableCell(withIdentifier: RechargeOptionCellReuseIdentifier) as! RechargeOptionCell
                    cell.configureWith(balance: balance, options: options, delegate: strongself)
                    return cell
                }
        	}
        )

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.envelope
            .subscribe(onNext: { [weak self] env in
                guard let StrongSelf = self else { return }
                StrongSelf.rechargeFromView = RechargeFromFooterView(methods: env.paymentMethods, delegate: StrongSelf)
        	})
        	.disposed(by: disposeBag)

        self.viewModel.envelope
            .map { env in
                return
                    [
                        RechargeSectionModel.optionSection(items: [RechargeSectionItem.optionSectionItem(balance: env.balance ?? "0", options: env.options)])
                    ]
            }
            .bind(to: tableView.rx.items(dataSource: dataSources))
            .disposed(by: disposeBag)

		/// 查询支付状态
        self.viewModel.queryedResult
            .drive(onNext: { [weak self] env in

                guard let StrongSelf = self else { return }

                if env.code == String(GashaponmachinesError.success.rawValue) {
                    delay(1) {
                        HUD.shared.dismiss()
                        HUD.success(second: 1.5, text: "充值成功", completion: {
                            StrongSelf.delegate?.rechargeSuccess()
                            StrongSelf.navigationController?.pushViewController(RechargeRecordViewController(), animated: true)
                        })
                    }
                } else {
                    if StrongSelf.viewModel.retryQueryCount.value < RechargeViewController.maxRetryQueryCount {
                        delay(1.5) {
                            StrongSelf.viewModel.alipayOutTradeNumber.onNext(env.outTradeNumber)
                            StrongSelf.viewModel.retryQueryCount.accept(StrongSelf.viewModel.retryQueryCount.value + 1)
                        }
                    } else {
                        HUD.shared.dismiss()
                        let str = "由于支付平台网络延迟，此单号 \(env.outTradeNumber) 正在处理中，请勿重复提交订单。稍后在右上角充值明细处查看订单是否成功。点击确定将保存截图，若有疑问请联系客服处理。"
                        HUD.alert(title: "充值确认中", message: str)
                    }
                }
            })
        	.disposed(by: disposeBag)

        self.viewModel.isRechargeButtonEnable
            .drive(self.rechargeButton.rx.isEnabled)
            .disposed(by: disposeBag)

        /// 支付宝订单
        self.viewModel.alipayOrder
            .subscribe(onNext: { env in
                AlipayApiManager.shared.payOrder(orderStr: env.sign, callback: { res in
                    print(res.debugDescription)
                })
            })
            .disposed(by: disposeBag)

        /// 微信订单
        self.viewModel.wechatOrder
            .mapToWechat()
            .subscribe(onNext: { env in
                WXApiManager.wechatPay(env: env)
        	})
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
        	.disposed(by: disposeBag)
    }

    @objc func goToRechargeRecord() {
        self.navigationController?.pushViewController(RechargeRecordViewController(), animated: true)
    }

    override func willMove(toParent parent: UIViewController?) {
        if isOpenFromGameView {
            self.navigationController?.navigationBar.barTintColor = .qu_yellow
            self.navigationController?.navigationBar.tintColor = .qu_black
        }
    }
}

extension RechargeViewController: AlipayApiManagerDelegate {

    func didCancelRecharge() {}

    func didReceiveOutTradeNumber(num: String) {
        self.viewModel.alipayOutTradeNumber.onNext(num)
    }
}

extension RechargeViewController: RechargeOptionCellDelegate {
    func didSelectedPaymentOption(amount: Double) {
        self.viewModel.selectedAmount.onNext(amount)
    }
}

extension RechargeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            return indexPath
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return RechargeHeaderViewHeight
        case 1:
            return 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.rechargeFromView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(self.rechargeFromView.methods.count * 52)
    }
}

extension RechargeViewController: RechargeFromFooterViewDelegate {

    func didSelectedMethod(method: PaymentMethod) {

        self.viewModel.selectedPay.onNext(method)
    }
}

extension RechargeViewController: WXApiManagerDelegate {
    func didReceiveAuthResponse(resp: SendAuthResp) {}

    func didReceivePayResponse(resp: PayResp) {
        HUD.shared.persist(text: "支付中")
        if resp.errCode == WXSuccess.rawValue {
            self.viewModel.queryWechatPayResultTrigger.onNext(())
        } else if resp.errCode == WXErrCodeUserCancel.rawValue {
            HUD.shared.dismiss()
            HUD.showError(text: "取消支付", completion: nil)
        } else if resp.errCode == WXErrCodeAuthDeny.rawValue {
            HUD.shared.dismiss()
            HUD.showError(text: "授权失败", completion: nil)
        } else if resp.errCode == WXErrCodeSentFail.rawValue {
            HUD.shared.dismiss()
            HUD.showError(text: "发送支付请求失败", completion: nil)
        } else {
            HUD.shared.dismiss()
            HUD.showError(text: "无法支付，签名错误或其他原因", completion: nil)
        }
    }
}
