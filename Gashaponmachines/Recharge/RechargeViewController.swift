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

    var paymentPlanListEnvelope: PaymentPlanListEnvelope?

    var isOpenFromGameView: Bool = false

    var rechargeFromView: RechargeFromFooterView!

    var viewModel: RechargeViewModel!

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 4
        tv.layer.masksToBounds = true
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tv.dataSource = self
        tv.delegate = self
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
        rechargeButton.layer.cornerRadius = 8
        rechargeButton.layer.masksToBounds = true
        rechargeButton.setBackgroundColor(color: .qu_cyanGreen, forUIControlState: .normal)
        return rechargeButton
    }()
    
    let balanceLabel = UILabel.numberFont(size: 24)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DanmakuService.shared.alertDelegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.viewWillAppearTrigger.onNext(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DanmakuService.shared.showAlert(type: .Recharge)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        BugTrackService<UserTrackEvent>.writeEventToFile(event: .Recharge)

        WXApiManager.shared.delegate = self
        AlipayApiManager.shared.delegate = self
        
        self.view.backgroundColor = .white
        
        let bgView = UIView.withBackgounrdColor(.qu_yellow)
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(183)
        }
        
        let bgIv = UIImageView(image: UIImage(named: "recharge_nav_bg"))
        bgView.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let nav = CustomNavigationBar()
        nav.title = "\(AppEnvironment.reviewKeyWord)充值"
        nav.backgroundColor = .clear
        nav.setupRightButton(imageName: "recharge_details", target: self, selector: #selector(goToRechargeRecord))
        view.addSubview(nav)
        nav.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }

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
        
        let valueLabel = UILabel.with(textColor: .black, boldFontSize: 28, defaultText: "我的元气:")
        valueLabel.textAlignment = .left
        view.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(nav.snp.bottom)
            make.left.equalTo(12)
            make.height.equalTo(60)
        }
        
        balanceLabel.textColor = .black
        view.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.left.equalTo(valueLabel.snp.right).offset(6)
            make.centerY.height.equalTo(valueLabel)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(bottomView.snp.top)
        }

        rechargeFromView = RechargeFromFooterView(delegate: self)
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel = RechargeViewModel(rechargeButtonTap: self.rechargeButton.rx.tap.asSignal())

        // 支付列表数据
        self.viewModel.envelope
            .subscribe(onNext: { [weak self] env in
                guard let StrongSelf = self else { return }
                StrongSelf.paymentPlanListEnvelope = env
                StrongSelf.balanceLabel.text = env.balance
                StrongSelf.tableView.reloadData()
        	})
        	.disposed(by: disposeBag)

        self.viewModel.isRechargeButtonEnable
            .drive(self.rechargeButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // 查询订单请求失败
        self.viewModel.queryOrderError
            .subscribe(onNext: { env in
                HUD.shared.dismiss()
                HUD.alert(title: "网络不佳", message: "无法链接到服务器，请前往充值明细查看结果")
            })
            .disposed(by: disposeBag)

        // 查询支付状态
        self.viewModel.queryedResult
            .drive(onNext: { [weak self] env in

                guard let StrongSelf = self else { return }

                if env.code == String(GashaponmachinesError.success.rawValue) {
                    delay(1) {
                        HUD.shared.dismiss()
                        NotificationCenter.default.post(name: .refreshYiFanShangDetail, object: nil)
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

        // 支付宝订单
        self.viewModel.alipayOrder
            .subscribe(onNext: { env in
                AlipayApiManager.shared.payOrder(orderStr: env.sign, callback: { res in
                    QLog.debug(res.debugDescription)
                })
            })
            .disposed(by: disposeBag)

        // 微信订单
//        self.viewModel.wechatOrder
//            .mapToWechat()
//            .subscribe(onNext: { env in
//                WXApiManager.wechatPay(env: env)
//        	})
//            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
        	.disposed(by: disposeBag)
    }

    @objc func goToRechargeRecord() {
        self.navigationController?.pushViewController(RechargeRecordViewController(), animated: true)
    }
}

extension RechargeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RechargeOptionCellReuseIdentifier, for: indexPath) as! RechargeOptionCell
        if let env = paymentPlanListEnvelope {
            cell.configureWith(balance: env.balance, paymentPlans: env.paymentPlanList, delegate: self)
        }
        return cell
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
        if let env = paymentPlanListEnvelope {
            let row = ceil(CGFloat(env.paymentPlanList.count/2))
            return 20 + row * (RechargeHeaderViewOptionButtonHeight + 12)
        } else {
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
        return 92
    }
}

extension RechargeViewController: RechargeFromFooterViewDelegate {

    func didSelectedMethod(method: PaymentMethod) {
        self.viewModel.selectedPay.onNext(method)
    }
}

extension RechargeViewController: RechargeOptionCellDelegate {
    func didSelectedPaymentOption(paymentPlan: PaymentPlan) {
        self.rechargeFromView.updatePaymentButton(methods: paymentPlan.paymentMethods)

        if let amount = Double(paymentPlan.amount), amount > 0 {
            self.viewModel.selectedAmount.onNext(amount)
            self.viewModel.paymentPlanId.onNext(paymentPlan.paymentPlanId)
        } else {
            HUD.showError(second: 2, text: "充值金额异常", completion: nil)
        }
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

extension RechargeViewController: AlipayApiManagerDelegate {

    func didCancelRecharge() {}

    func didReceiveOutTradeNumber(num: String) {
        HUD.shared.persist(text: "支付中")
        self.viewModel.alipayOutTradeNumber.onNext(num)
    }
}
