// 霸机充值
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

private let HeightOf32BoldPixel = UIFont.heightOfBoldPixel(32)
private let HeightOf24Pixel = UIFont.heightOfPixel(24)
private let ContainerViewContentHeight: CGFloat = 233.5 + HeightOf32BoldPixel + HeightOf24Pixel + OccupyRechargeOptionCellButtonHeight + CellHeight * 2
//private let ContainerViewHeight = ContainerViewContentHeight + Constants.kScreenBottomInset + 12 + UIFont.heightOfPixel(24) + 12
private let ContainerViewHeight = 486 + Constants.kScreenBottomInset
private let CellHeight: CGFloat = 52
//private let IconSize: CGFloat = 50
private let CloseButtonSize: CGFloat = 25

private let OccupyRechargeOptionCellReuseIdentifier = "OccupyRechargeOptionCellReuseIdentifier"

protocol OccupyRechargeViewControllerDelegate: class {

    //  取消霸机 或者 霸机超时
    func occupyRechargeViewControllerDidTimeout()

    // 充值完
    func occupyRechargeViewControllerDidRecharge(status: OccupyRechageStatus)

    // 整个页面退出
    func willDismissViewController()
}

class OccupyRechargeViewController: BaseViewController {

    var gameViewModel: GameViewModel!

    var rechargeFinishVC: OccupyRechargeFinishViewController?

    var rechargeQueryVC: OccupyRechargeQueryViewController?

    var viewModel: OccupyRechargeViewModel!

    /// 是否正在显示查询弹窗
    var isShowQueryVC: Bool = false

    weak var timer: Timer?

    weak var rechargeDelegate: Rechargable?

    weak var delegate: OccupyRechargeViewControllerDelegate?

    // 倒数总时间
    private var totalCountDown: Int = 90

    // 机台花费
    var amount: Int

    var isMunualRecharge: Bool = false

    var dataSources: RxTableViewSectionedReloadDataSource<RechargeSectionModel>!

    private let timerLabel = UILabel.with(textColor: .qu_black, fontSize: 24)

    // 查询倒计时
    private var queryCountDown: Int = -1

    private var rechargeButton: UIButton = {
        let btn = UIButton()

        let totalStr = "+ 霸机充值"
        let string = NSMutableAttributedString(string: totalStr, attributes: [
            NSAttributedString.Key.font: UIFont.withBoldPixel(32),
            NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        let range = totalStr.range(of: "+")!
        let nsRange = NSRange(range, in: totalStr)
        string.addAttributes([NSAttributedString.Key.font: UIFont.withBoldPixel(40)], range: nsRange)
        btn.setAttributedTitle(string, for: .normal)
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.setBackgroundColor(color: .qu_cyanGreen, forUIControlState: .normal)
        return btn
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton.with(imageName: "input_close")
        button.addTarget(self, action: #selector(cancelRecharge), for: .touchUpInside)
        return button
    }()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.isScrollEnabled = false
        tv.register(OccupyRechargeOptionCell.self, forCellReuseIdentifier: OccupyRechargeOptionCellReuseIdentifier)
        return tv
    }()

    private let container = UIView.withBackgounrdColor(.white)

    var rechargeFromView: OccupyRechargeFromFooterView?

    // MARK: - 初始化方法
    init(roomId: String, delegate: OccupyRechargeViewControllerDelegate?, amount: Int, ttl: TimeInterval?, isMunualRecharge: Bool) {
        self.amount = amount
        self.isMunualRecharge = isMunualRecharge

        if let ttl = ttl {
            self.totalCountDown = Int(ttl / 1000)
        } else {
            self.totalCountDown = 90
        }

        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.gameViewModel = GameViewModel(roomId: roomId)
        self.viewModel = OccupyRechargeViewModel(roomId: roomId, rechargeSignal: self.rechargeButton.rx.tap.asSignal())
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {

        view.backgroundColor = UIColor.qu_popBackgroundColor

        container.layer.cornerRadius = 12
        view.addSubview(container)
        container.frame = CGRect(x: 0,
                                 y: Constants.kScreenHeight,
                                 width: Constants.kScreenWidth,
                                 height: ContainerViewHeight)

        let icon = UIImageView(image: UIImage(named: "occupy_logo"))
        icon.frame = CGRect(x: (Constants.kScreenWidth - 279)/2, y: -70, width: 279, height: 114)
        container.addSubview(icon)
        
        let topContainer = UIView.withBackgounrdColor(.clear)
        topContainer.frame = CGRect(x: 0, y: icon.bottom, width: Constants.kScreenWidth, height: 88)
        container.addSubview(topContainer)

        let titleLabel = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "元气不足，现可霸机充值哦！")
        titleLabel.frame = CGRect(x: 0, y: 24, width: Constants.kScreenWidth, height: UIFont.heightOfBoldPixel(32))
        titleLabel.centerX = icon.centerX
        titleLabel.textAlignment = .center
        topContainer.addSubview(titleLabel)

        container.addSubview(closeButton)
        closeButton.frame = CGRect(x: Constants.kScreenWidth - 8 - CloseButtonSize, y: 8, width: CloseButtonSize, height: CloseButtonSize)

        timerLabel.textAlignment = .center
        timerLabel.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: UIFont.heightOfPixel(24))
        timerLabel.top = titleLabel.bottom + 12
        timerLabel.centerX = icon.centerX
        topContainer.addSubview(timerLabel)
        
        tableView.frame = CGRect(x: 0, y: topContainer.bottom, width: Constants.kScreenWidth, height: 260)
        container.addSubview(tableView)
        
        let bottomContainer = UIView.withBackgounrdColor(.clear)
        bottomContainer.frame = CGRect(x: 0, y: tableView.bottom, width: Constants.kScreenWidth, height: 94)
        container.addSubview(bottomContainer)
        
        bottomContainer.addSubview(rechargeButton)
        rechargeButton.frame = CGRect(x: 12,
                                      y: 16,
                                      width: Constants.kScreenWidth - 24,
                                      height: 44)

        let tipLabel = UILabel.with(textColor: .new_lightGray, fontSize: 20, defaultText: "** 霸冲是否成功取决于支付渠道结果返回，请勿过分依赖 **")
        tipLabel.frame = CGRect(x: 0, y: rechargeButton.bottom + 8, width: Constants.kScreenWidth, height: tipLabel.font.lineHeight)
        tipLabel.textAlignment = .center
        bottomContainer.addSubview(tipLabel)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.container.frame = CGRect(x: 0, y: Constants.kScreenHeight - ContainerViewHeight, width: Constants.kScreenWidth, height: ContainerViewHeight)
            self.view.layoutIfNeeded()
        }, completion: { finish in
            if !self.isMunualRecharge {
                self.showRechargeFinishView()
            }
        })

        createNewTimer()
    }

    // MARK: - 系统方法
    override func viewDidLoad() {
        super.viewDidLoad()
        WXApiManager.shared.delegate = self
        AlipayApiManager.shared.delegate = self

        self.viewModel.viewDidLoadTrigger.onNext(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.stopTimer()
        self.rechargeFinishVC?.dismiss(animated: true, completion: nil)
        self.rechargeQueryVC?.dismiss(animated: true, completion: nil)
        HUD.shared.dismiss()
    }

    // MARK: - 私有方法
    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.dataSources = RxTableViewSectionedReloadDataSource<RechargeSectionModel>(
            configureCell: { [weak self] (ds, tv, ip, _) in
                switch ds[ip] {
                case let .optionSectionItem(_, options):
                    guard let StrongSelf = self else { return OccupyRechargeOptionCell() }
                    let cell: OccupyRechargeOptionCell = tv.dequeueReusableCell(withIdentifier: OccupyRechargeOptionCellReuseIdentifier) as! OccupyRechargeOptionCell
                   	cell.configureWith(options: options, delegate: StrongSelf)
                    return cell
                }
        })

        self.viewModel.getRechargeListError
            .subscribe(onNext: { [weak self] _ in
                HUD.shared.dismiss()
                // 如果无法加载充值方法，就使用预加载的充值列表
                self?.useDefaultRechargeOption()
            })
            .disposed(by: disposeBag)

        self.viewModel.rechargeListEnv
            .do(onSubscribe: {
                HUD.shared.persist(text: "", timeout: 5)
            })
            .subscribe(onNext: { [weak self] env in
                HUD.shared.dismiss()
                guard let StrongSelf = self else { return }
                let model = [
                    RechargeSectionModel.optionSection(items: [RechargeSectionItem.optionSectionItem(balance: "0", options: env.options)])
                ]
                StrongSelf.viewModel.options.accept(model)
                StrongSelf.rechargeFromView = OccupyRechargeFromFooterView(methods: env.paymentMethods, delegate: StrongSelf)
            })
        	.disposed(by: disposeBag)

        self.viewModel.options
            .bind(to: tableView.rx.items(dataSource: dataSources))
            .disposed(by: disposeBag)

        // 查询房间信息失败
        self.gameViewModel.roomInfoError
            .subscribe(onNext: { [weak self] env in
                guard let StrongSelf = self else { return }
                if StrongSelf.isShowQueryVC {
                    delay(3.0) {
                        StrongSelf.gameViewModel.refreshBalanceTrigger.onNext(())
                    }
                }
            })
            .disposed(by: disposeBag)

        // 查询房间信息
        self.gameViewModel.roomInfo
            .subscribe(onNext: { [weak self] roomInfo in
                guard let StrongSelf = self else { return }

                if let banlance = Int(roomInfo.balance),
                    let price = Int(roomInfo.machinePrice) {

                    if banlance >= price { // 查询成功
                        StrongSelf.rechargeQueryVC?.dismissVc()
                        StrongSelf._rechargeSuccess(timeout: false)
                    } else { // 查询失败, 则3s查一次
                        delay(3.0) {
                            StrongSelf.gameViewModel.refreshBalanceTrigger.onNext(())
                        }
                    }

                } else {
                    HUD.showError(second: 1.5, text: "充值信息有误", completion: nil)
                }
            })
            .disposed(by: disposeBag)

        /// 支付宝订单
        self.viewModel.alipayOrder
            .subscribe(onNext: { env in
                AlipayApiManager.shared.payOrder(orderStr: env.sign, callback: { res in
                    // do nothing
                })
            })
            .disposed(by: disposeBag)

        /// 微信订单
//        self.viewModel.wechatOrder
//            .mapToWechat()
//            .subscribe(onNext: { env in
//                WXApiManager.wechatPay(env: env)
//            })
//            .disposed(by: disposeBag)

        self.viewModel.rechargeError
            .subscribe(onNext: { env in
            	HUD.showErrorEnvelope(env: env)
        	})
        	.disposed(by: disposeBag)

        self.rechargeButton.rx.tap
        	.asDriver()
            .delay(.seconds(1))
            .drive(onNext: { [weak self] in
                BugTrackService<UserTrackEvent>.writeEventToFile(event: .OccupyRecharge)
                self?.showRechargeFinishView()
            })
        	.disposed(by: disposeBag)
    }

    private func useDefaultRechargeOption() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        guard let asset = delegate.viewModel.staticAssets, let options = asset.paymentOptions, let methods = asset.paymentMethods  else { return }

        // 拿到第一个符合条件的
        let preloadOptions = options.filter { self.amount <= Int($0.priceLimit)! }.first
        guard let opts = preloadOptions else { return }
        let model = [
            RechargeSectionModel.optionSection(items: [RechargeSectionItem.optionSectionItem(balance: "0", options: opts.options)])
        ]
        self.viewModel.options.accept(model)
        self.rechargeFromView = OccupyRechargeFromFooterView(methods: methods, delegate: self)
    }

    /// 充值结束弹窗
    private func showRechargeFinishView() {
        let vc = OccupyRechargeFinishViewController(traceTime: totalCountDown)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
        self.rechargeFinishVC = vc
    }

    /// 查询充值结果弹窗
    private func showQueryResultView() {
        self.isShowQueryVC = true
        let vc = OccupyRechargeQueryViewController(traceTime: totalCountDown)
        self.present(vc, animated: true, completion: nil)
        vc.timeOverHandle = { [weak self] in // 15s超时
            self?.isShowQueryVC = false
            self?.showRechargeErrorView()
        }
        self.rechargeQueryVC = vc
    }

    /// 充值查询失败弹窗
    private func showRechargeErrorView() {
        let vc = OccupyRechargeErrorViewController()
        self.present(vc, animated: true, completion: nil)
    }

    /// 定时器
    func createNewTimer() {

        if timer != nil {
            stopTimer()
        }

        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(count), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    private func _rechargeSuccess(timeout: Bool) {
        HUD.shared.dismiss()
        self.delegate?.occupyRechargeViewControllerDidRecharge(status: .success)
        self.rechargeDelegate?.rechargeSuccess()
        dismissVC()
    }

    private func dismissVC() {

        stopTimer()

        self.rechargeQueryVC?.dismiss(animated: true, completion: nil)
        self.rechargeFinishVC?.dismiss(animated: true, completion: nil)

        UIView.animate(withDuration: 0.2, animations: {
            self.container.frame = CGRect(x: 0, y: Constants.kScreenHeight, width: Constants.kScreenWidth, height: ContainerViewHeight)
            self.view.layoutIfNeeded()
        }, completion: { finish in
            self.delegate?.willDismissViewController()
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }

    // MARK: - 监听方法
    @objc func cancelRecharge() {
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .CancelOccupy)
        let vc = OccupyConfirmQuitViewController(remainSecond: self.totalCountDown)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }

    @objc func count() {
        totalCountDown -= 1
        timerLabel.text = "霸机中：\(totalCountDown)s"
        // 过了90s
        if totalCountDown <= 0 {
            HUD.shared.dismiss()
            self.delegate?.occupyRechargeViewControllerDidRecharge(status: .timeout)
            dismissVC()
        }
    }
}

extension OccupyRechargeViewController: Rechargable {

    func rechargeFail() {
        self.rechargeFinishVC?.dismiss(animated: true, completion: nil)
    }

    func rechargeSuccess() {
        self.rechargeFinishVC?.dismiss(animated: true, completion: nil)
        showQueryResultView()
        self.gameViewModel.refreshBalanceTrigger.onNext(())
    }
}

extension OccupyRechargeViewController: OccupyConfirmQuitViewControllerDelegate {

    func quitButtonDidTapped() {
        self.delegate?.occupyRechargeViewControllerDidTimeout()
        self.dismissVC()
    }
}

extension OccupyRechargeViewController: RechargeFromFooterViewDelegate {

    func didSelectedMethod(method: PaymentMethod) {
        self.viewModel.selectedPay.onNext(method)
    }
}

extension OccupyRechargeViewController: OccupyRechargeOptionCellDelegate {

    func didSelectedPaymentOption(amount: Double) {
        self.viewModel.selectedAmount.onNext(amount)
    }
}

extension OccupyRechargeViewController: AlipayApiManagerDelegate {

    // 充值完成后, 支付宝返回订单编号
    func didReceiveOutTradeNumber(num: String) {
        self.rechargeFinishVC?.dismiss(animated: true, completion: nil)
        delay(1.0) {
            self.showQueryResultView()
            self.gameViewModel.refreshBalanceTrigger.onNext(())
        }
    }

    func didCancelRecharge() {
        self.rechargeFinishVC?.dismiss(animated: true, completion: nil)
    }
}

extension OccupyRechargeViewController: WXApiManagerDelegate {
    func didReceiveAuthResponse(resp: SendAuthResp) {}

    // 充值成功
    func didReceivePayResponse(resp: PayResp) {
        self.rechargeFinishVC?.dismiss(animated: true, completion: nil)
        if resp.errCode == WXSuccess.rawValue {
            delay(1.0) {
                self.showQueryResultView()
                self.gameViewModel.refreshBalanceTrigger.onNext(())
            }
        } else if resp.errCode == WXErrCodeUserCancel.rawValue {
            HUD.showError(text: "取消支付", completion: nil)
        } else if resp.errCode == WXErrCodeAuthDeny.rawValue {
            HUD.showError(text: "授权失败", completion: nil)
        } else if resp.errCode == WXErrCodeSentFail.rawValue {
            HUD.showError(text: "请求失败", completion: nil)
        } else {
            HUD.showError(text: "无法支付，签名错误或其他原因", completion: nil)
        }
    }
}

extension OccupyRechargeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 127
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
        return 117
    }
}
