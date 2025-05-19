// 扭蛋页
import UIKit
import RxCocoa
import RxSwift
import SnapKit
import CoreGraphics
import Argo
import StoreKit
import ESTabBarController_swift
import SwiftState

struct GameConstants {
    static let SegmentControlHeight: CGFloat = 52
}

private let GameGuideUserDefaultIdentifier = "GameGuideUserDefaultIdentifier"

class GameNewViewController: BaseViewController {

    /// 是否为一键返回机台
    var isBackGame: Bool = false

    /// 暴击信息
    private var powerInfo: PowerInfo? {
        didSet {
            criticalView.powerInfo = powerInfo
        }
    }

    private var randomStr: String {
        return String.random(length: 6)
    }

    // 是否为手动点击霸机充值()
    var isMunualRecharge: Bool = false

    /// 房间信息
    private var roomInfo: RoomInfoEnvelope? {
        didSet {
            criticalView.isHidden = roomInfo?.powerInfo == nil ? true: false

            self.criticalView.machine = roomInfo?.machine
            self.powerInfo = roomInfo?.powerInfo

            if !AppEnvironment.isReal {
                self.gameIdleButton.price = roomInfo?.machinePrice
            }
            self.exchangeButton.configureWith(info: roomInfo)
            self.rechargeButton.configureWith(info: roomInfo)
        }
    }

    /// 房间号
    private var roomNumber: String

    /// 扭蛋订单号
    private var orderId: String?

    var viewModel: GameViewModel

    private var showedPopView = false

    private var canScroll: Bool = true

    /// 补充元气弹窗
    lazy var rechargePopView: GameRechargePopView = {
        let view = GameRechargePopView()
        view.isHidden = true
        view.addButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                view.isHidden = true
                let vc = RechargeViewController(isOpenFromGameView: true)
                vc.delegate = self
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: view.disposeBag)
        return view
    }()

    /// 游戏结束弹窗
    lazy var popOverView: GamePopOverView = {
        let view = GamePopOverView(delegate: self)
        view.isHidden = true
        view.isBackGame = self.isBackGame
        return view
    }()

    /// 高斯模糊背景
    var loadingLogoView: UIImageView
    /// 提示框
    let tipView = GameNewTipView()

    lazy var gameTableView: GameTableView = {
        let tv = GameTableView(frame: .zero, style: .grouped)
        tv.delegate = self
        tv.showsVerticalScrollIndicator = false
        tv.backgroundColor = .clear
        tv.dataSource = self
        tv.bounces = false
        tv.allowsSelection = false
        tv.separatorStyle = .none
        return tv
    }()

    /// 播放器背景视图
    lazy var playerView: UIView = {
        let playerView = UIView()
        playerView.backgroundColor = .white
        playerView.layer.cornerRadius = 8
        playerView.layer.masksToBounds = true
        return playerView
    }()

    /// 状态栏颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    /// 最高奖赏视图
    lazy var exchangeButton        = GameNewExchangeButton()
    /// 充值按钮
    lazy var rechargeButton       = GameNewRechargeButton()
    /// 左上角状态视图
    lazy var statusView         = GameNewStatusView()
    /// 正在扭蛋的旋转按钮
    lazy var gamePlayingButton = GameNewPlayingButton()
    /// 右上角用户信息视图
    lazy var realTimeInfoView  = GameNewRealtimeInfoView()
    /// 倒计时
    lazy var countdownView     = GameNewCountdownView()
    /// 开始扭蛋按钮
    lazy var gameIdleButton    = GameNewIdleButton()
    /// 退出按钮
    lazy var exitButton        = GameNewExitButton()
    /// 客服按钮
    lazy var reportButton      = GameNewReportButton()

    //
    private var containerCell: GameContainerCell?
    /// 播放器
    private var liveStreamPlayer: GameMoviePlayerController?

    /// 切换标题视图
    lazy var sectionView: GameSegmentSectionView = {
        let view = GameSegmentSectionView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 52))
        view.selectIndex = 0
        view.indexChangeHandle = { [weak self] index in
            self?.containerCell?.isSelectedIndex = true
            self?.containerCell?.scrollView.setContentOffset(CGPoint(x: CGFloat(index) * Constants.kScreenWidth, y: 0), animated: true)
        }
        return view
    }()

    /// 网络断开连接弹窗
    private var badNetworkPopView: BadNetworkPopView!

    /// 暴击视图
    lazy var criticalView: GameNewCriticalView = {
        let v = GameNewCriticalView()
        v.isHidden = true
        v.delegate = self
        return v
    }()

    /// 游戏将在多少秒内开始
    var gameWillStartInSec: TimeInterval = 10

    /// 暴击倒计时
    weak var criticalTimer: Timer?

    /// 使用暴击个数
    var usedCritCount: Int = 0

    /// 暴击状态
    var criticalState: CriticalState = .normal {
        didSet {
            criticalView.criticalState = criticalState
        }
    }

    /// 导航栏
    var navigationBar = GameNavigationBar()

    /// 心跳包定时器
    var heartPackageTimer: Timer?

    /// 网络差弹窗
    let networkStateView = GameNetworkStateView()
    
    /// 顶部标题背景
    let titleView = UIView.withBackgounrdColor(.clear)
    /// 顶部标题
    let titleLb = UILabel.with(textColor: UIColor(hex: "9A4312")!, boldFontSize: 32)
    /// 顶部标题滚动方向
    var isScrollToLeft = true

    // MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.delegate = self
        removeBackCurrentGameButton()
        removeOldPlayer()
        gameTableView.tableHeaderView = setupHeaderView()
        self.liveStreamPlayer?.prepareToPlay()
        AudioService.shared.play(audioType: .bgm)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 展示运营弹窗
        DanmakuService.shared.showAlert(type: .Game)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SocketService.shared.gameHandler = self
        SocketService.shared.statusHandler = self
        DanmakuService.shared.delegate = self
        DanmakuService.shared.alertDelegate = self

        self.showBadNetworkView()

        self.setupUI()

        self.rightButtonClick()

        self.gameIdleButtonClick()

        self.addNotification()

        self.joinRoom()

        self.viewModel.refreshBalanceTrigger.onNext(())

        self.showUserGuidePopVc()

        self.createHeartPackageTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = self.liveStreamPlayer, player.isPlaying() {
            player.stop()
        }
        removeOldPlayer()
        AudioService.shared.stop()
        self.popOverView.stopTimer()

        self.badNetworkPopView.isHidden = true
    }

    // MARK: - Initialize
    init(physicId: String, type: MachineColorType) {
        self.viewModel = GameViewModel(roomId: physicId)
        self.roomNumber = physicId
        self.loadingLogoView = UIImageView(image: type.loadingImage)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化头部视图
    private func setupHeaderView() -> UIView {
        let bgViewH = (Constants.kScreenWidth - 24) * (4/3)
        let headerViewH = 12 + bgViewH + 138
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: headerViewH))
        headerView.backgroundColor = .clear
        
        let bgIv = UIImageView(image: UIImage(named: "game_header_bg"))
        headerView.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let bgView = UIView.withBackgounrdColor(.white)
        bgView.layer.cornerRadius = 12
        bgView.layer.masksToBounds = true
        headerView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(bgViewH)
        }

        bgView.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.bottom.equalTo(-4)
        }

        playerView.addSubview(loadingLogoView)
        loadingLogoView.snp.makeConstraints { make in
            make.edges.equalTo(playerView)
        }

        loadingLogoView.addSubview(tipView)
        tipView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalTo(-52)
            make.width.equalTo(198)
        }

        playerView.addSubview(countdownView)
        countdownView.isHidden = true
        countdownView.snp.makeConstraints { make in
            make.edges.equalTo(playerView)
        }

        playerView.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.height.equalTo(36)
            make.width.greaterThanOrEqualTo(85)
        }

        playerView.addSubview(realTimeInfoView)
        realTimeInfoView.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalTo(statusView)
            make.width.equalTo(172)
            make.height.equalTo(32)
        }

        if !AppEnvironment.isReal {
            playerView.addSubview(criticalView)
            criticalView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        exitButton.addTarget(self, action: #selector(leave), for: .touchUpInside)
        bgView.addSubview(exitButton)
        exitButton.snp.makeConstraints { make in
            make.top.equalTo(80)
            make.left.equalToSuperview()
            make.width.equalTo(52)
            make.height.equalTo(44)
        }

        reportButton.addTarget(self, action: #selector(switchToFAQ), for: .touchUpInside)
        bgView.addSubview(reportButton)
        reportButton.snp.makeConstraints { make in
            make.centerY.size.equalTo(exitButton)
            make.right.equalToSuperview()
        }
        
        if let player = self.liveStreamPlayer {
            player.shutdown()
            self.liveStreamPlayer = nil
        }
        self.liveStreamPlayer = setupPlayer(liveAddress: roomInfo?.liveAddress ?? "")
        self.liveStreamPlayer?.prepareToPlay()
        if let player = self.liveStreamPlayer {
            playerView.insertSubview(player.view, belowSubview: countdownView)
            player.view.snp.makeConstraints { make in
                make.center.width.equalToSuperview()
                make.height.equalToSuperview().offset(-3)
            }
        }
        
        let midLine = UIView.withBackgounrdColor(.new_yellow)
        midLine.layer.cornerRadius = 8
        headerView.addSubview(midLine)
        midLine.snp.makeConstraints { make in
            make.top.equalTo(bgView.snp.bottom).offset(44)
            make.bottom.equalTo(-44)
            make.right.equalTo(-174)
            make.width.equalTo(2)
        }

        // 最高奖赏视图
        headerView.addSubview(exchangeButton)
        exchangeButton.snp.makeConstraints { make in
            make.left.equalTo(bgView)
            make.centerY.equalTo(midLine)
            make.height.equalTo(106)
            make.right.equalTo(midLine.snp.left).offset(-8)
        }

        headerView.addSubview(rechargeButton)
        rechargeButton.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.left.equalTo(midLine.snp.right).offset(8)
            make.bottom.equalTo(exchangeButton)
            make.height.equalTo(32)
        }

        headerView.addSubview(gameIdleButton)
        gameIdleButton.snp.makeConstraints { make in
            make.left.right.equalTo(rechargeButton)
            make.bottom.equalTo(rechargeButton.snp.top).offset(-8)
            make.height.equalTo(62)
        }

        headerView.addSubview(gamePlayingButton)
        gamePlayingButton.addTarget(self, action: #selector(startNow), for: .touchUpInside)
        gamePlayingButton.snp.makeConstraints { make in
            make.centerX.equalTo(exchangeButton)
            make.bottom.equalToSuperview().offset(-4)
            make.size.equalTo(179)
        }
        
//        let leftIv = UIImageView(image: UIImage(named: "game_n_header_left"))
//        headerView.addSubview(leftIv)
//        leftIv.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.centerY.equalTo(exchangeButton)
//        }

        bgView.addSubview(popOverView)
        popOverView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bgView.addSubview(rechargePopView)
        rechargePopView.snp.makeConstraints { make in
            make.edges.equalTo(playerView)
        }

        networkStateView.isHidden = true
        playerView.addSubview(networkStateView)
        networkStateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-16)
            make.width.equalTo(192)
            make.height.equalTo(28)
        }

        return headerView
    }

    private func setupUI() {
        view.backgroundColor = .new_bgYellow
        
        let topBgIv = UIImageView(image: UIImage(named: "game_n_top_bg"))
        view.addSubview(topBgIv)
        topBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        let topLogoIv = UIImageView(image: UIImage(named: "game_n_top_logo"))
        view.addSubview(topLogoIv)
        topLogoIv.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.equalTo(12)
            make.width.equalTo(84)
            make.height.equalTo(44)
        }
        
        titleView.layer.masksToBounds = true
        view.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.equalTo(topLogoIv.snp.right)
            make.right.equalTo(-10)
            make.height.equalTo(44)
        }
        
        titleView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        view.addSubview(gameTableView)
        gameTableView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        navigationBar.backgroundColor = .qu_yellow
        navigationBar.alpha = 0.0
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }

        bindNavigationBar()
    }

    // MARK: Custom
    /// 标题左右滚动动画
    func scrollLabelAnimation() {
        guard let text = titleLb.text else { return }
        
        delay(2.0) { [weak self] in
            guard let self = self else { return }
            
            let strW = text.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 16))
            let maskViewW = Constants.kScreenWidth - 106
            if strW <= maskViewW { return }
            
            let differenceW = strW - maskViewW
            let duration = differenceW/15.0
            
            self.titleLb.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(self.isScrollToLeft ? -differenceW : 0)
            }
            UIView.animate(withDuration: duration) {
                self.titleView.layoutIfNeeded()
            } completion: { finished in
                if finished {
                    self.isScrollToLeft = !self.isScrollToLeft
                    self.scrollLabelAnimation()
                }
            }
        }
    }
    
    /// 创建心跳包定时器
    func createHeartPackageTimer() {
        if self.heartPackageTimer != nil { return }

        self.heartPackageTimer = Timer(timeInterval: 8.0, target: self, selector: #selector(emitHeartPackage), userInfo: nil, repeats: true)
        RunLoop.main.add(self.heartPackageTimer!, forMode: .common)
        self.heartPackageTimer?.fire()
    }

    /// 移除心跳包定时器
    func removeHeartPackageTimer() {
        self.heartPackageTimer?.invalidate()
        self.heartPackageTimer = nil
    }

    /// 加入房间
    private func joinRoom() {
        SocketService.shared.emitEvent(.userJoinRoom(roomId: roomNumber)) { [weak self] data in
            guard let self = self else { return }
            guard let real = data.first as? [String: Any], JSONSerialization.isValidJSONObject(real) else {
                QLog.error("Invalid json data returned from server.")
                return
            }

            if let code = real["code"] as? Int, code != 200 {
                self.badNetworkPopView.type = .machineError
                if let msg = real["msg"] as? String {
                    self.badNetworkPopView.descLb.text = msg
                }
                if self.badNetworkPopView.isHidden {
                    self.badNetworkPopView.isHidden = false
                }
            }
        }
    }

    /// 添加通知
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeScrollstate), name: NSNotification.Name(rawValue: "leaveTop"), object: nil)
    }
    
    /// 初始化播放器
    private func setupPlayer(liveAddress: String) -> GameMoviePlayerController {
        let player = GameMoviePlayerController(contentURLString: liveAddress)!
        return player
    }

    /// 移除播放器
    private func removeOldPlayer() {
        self.liveStreamPlayer?.stop()
        self.liveStreamPlayer?.shutdown()
        self.liveStreamPlayer?.view.removeFromSuperview()
        self.liveStreamPlayer = nil
    }

    /// 移除一键返回游戏的按钮
    private func removeBackCurrentGameButton() {
        if let window = UIApplication.shared.keyWindow {
            window.subviews.forEach { v in
                if v is IndexBackCurrentGameButton {
                    let view = v as! IndexBackCurrentGameButton
                    view.removeFromSuperview()
                }
            }
        }
    }

    // 重置
    private func reset() {
        countdownView.on(state: .reset)
        gamePlayingButton.on(state: .reset)
        gameIdleButton.on(state: .reset)
        popOverView.on(state: .reset)
        exchangeButton.on(state: .reset)
        criticalState = .gameDidFinished
        usedCritCount = 0
    }

    /// 处理Code码
   private func handleCode(env: GameStatusUpdatedEnvelope) {
       if env.code == "400" { // 错误
           self.showErrorStatusVc(title: env.msg)
       } else if env.code == "4100" { // 错误
           HUD.showError(second: 2.0, text: env.msg, completion: nil)
       } else if env.code == "4200" { // 余额不足
           self.rechargePopView.isHidden = false
       } else if env.code == "4400" || env.code == "5000" { // 机台故障
           let errorView = GameErrorView(title: env.title, msg: env.msg)
           UIApplication.shared.keyWindow?.addSubview(errorView)
           AudioService.shared.on(state: .err)
       }
   }

    /// 开始倒计时
    func startCountdown(from: TimeInterval) {
        self.gameWillStartInSec = from - 2
        self.criticalTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        self.criticalTimer?.fire()
    }

    // MARK: - Action
    /// 点击开始按钮
    @objc func playGame() {
        SocketService.shared.emitUserPlayGame(param: .ready(roomId: roomNumber, eventId: randomStr)) { _ in }
    }

    /// 使用暴击
    @objc func useCrit() {
        guard let orderId = self.orderId else { return }
        SocketService.shared.emitUserPlayGame(param: .crit(roomId: roomNumber, eventId: randomStr, orderId: orderId, critMultiple: usedCritCount)) { _ in }
    }

    /// 立刻开始
    @objc func startNow() {
        if self.gamePlayingButton.isRotating {
            AudioService.shared.play(audioType: .vibrate)
            return
        }

        guard let orderId = self.orderId else { return }
        self.criticalView.criticalState = .fired(usedCrit: false)

        SocketService.shared.emitUserPlayGame(param: .fire(roomId: roomNumber, eventId: randomStr, orderId: orderId)) { _ in}
    }

    // 在线客服
    @objc func switchToFAQ() {
        self.navigationController?.pushViewController(FAQViewController(), animated: true)
    }

    // 离开
    @objc func leave() {
        removeHeartPackageTimer()

        dismiss(animated: true) {
            SocketService.shared.emitEvent(.userLeaveRoom(roomId: self.roomNumber)) { data in
                QLog.debug("Socket emit event user_leave_room")
            }
            /// dismiss两次为了解决机台网络不佳弹窗问题
            self.dismiss(animated: true, completion: nil)
        }
    }

    func rightButtonClick() {
        self.rechargeButton.rx.tap
            .asDriver()
            .withLatestFrom(self.viewModel.showNDVipWarning.asDriver(onErrorJustReturn: false))
            .drive(onNext: { [weak self] show in
                guard let self = self else { return }
                if show {
                    self.showInAppPurchasePopView()
                } else {
                    let vc = RechargeViewController(isOpenFromGameView: true)
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    func gameIdleButtonClick() {
        // 开始扭蛋点击
        self.gameIdleButton.rx.tap
            .asDriver()
            .withLatestFrom(self.viewModel.showNDVipWarning.asDriver(onErrorJustReturn: false))
            .drive(onNext: { [weak self] show in
                guard let self = self else { return }
                if show {
                    self.showInAppPurchasePopView()
                } else {
                    self.playGame()
                }
            })
            .disposed(by: disposeBag)
    }

    @objc func tick() {
        if gameWillStartInSec < 0 {
            self.criticalTimer?.invalidate()
            self.criticalTimer = nil
            return
        }
        criticalState = .userStartGame(remainSec: gameWillStartInSec)
        gameWillStartInSec -= 1
    }

    /// 服务器是否返回数据
    var isReceived = false

    /// 当前心跳包的eventId
    var currentEventId: String!

    /// 发送心跳包
    @objc func emitHeartPackage() {

        isReceived = false
        currentEventId = self.randomStr

        // 两秒回调检测
        let timer = Timer(timeInterval: 2.0, target: self, selector: #selector(heartPackageTimeoutHandle), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)

        // 发送心跳包
        SocketService.shared.emitHeartPackage(eventId: currentEventId) { [weak self] data in
            guard let self = self else { return }
            guard let real = data.first as? [String: Any], JSONSerialization.isValidJSONObject(real) else {
                QLog.error("Invalid json data returned from server.")
                return
            }

            let realData = real["data"] as? [String: Any]
            let eventId = realData?["eventId"] as? String

            // eventId相同
            if eventId == self.currentEventId {
                self.isReceived = true
            }
        }
    }

    /// 心跳包2s超时回调
    @objc func heartPackageTimeoutHandle() {
        // 2s后若心跳接受不成功, 则视为超时, 弹出弹窗提示用户
        if !self.isReceived {
            networkStateView.isHidden = false
        } else {
            networkStateView.isHidden = true
        }
    }

    // MARK: - PopView
    /// 显示用户引导弹窗
    func showUserGuidePopVc() {
        let showDate = UserDefaults.standard.object(forKey: NewUserGuideMachineKey)
        if showDate == nil && !AppEnvironment.isReal && AppEnvironment.stage == .release {
            let vc = NewUserGuidePopViewController(guideType: .machine)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.didConfirmButtonClick = { [weak self] in
                self?.showPushPopVc()
            }
            self.present(vc, animated: true, completion: nil)
        }
    }

    /// 显示推送提醒弹窗
    func showPushPopVc() {
        let showDate = UserDefaults.standard.object(forKey: NewUserGuideMachineKey)
        if showDate != nil { // 保证先弹出新用户引导
            // 注册推送通知
            PushService.shared.registerIfNeed(on: self, confirmClosure: { [weak self] in
                PushService.shared.registerAPNS()
                }, cancelClosure: { [weak self] in
                    self?.showConfirmGuide()
            })
        }
    }

    /// 再次显示推送提示弹窗
    func showConfirmGuide() {
        let vc = PushNotificationConfirmViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.confirmButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                vc.dismiss(animated: true, completion: {
                    PushService.shared.registerAPNS()
                })
            })
            .disposed(by: vc.disposeBag)
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

    func showRulePopView() {
        let vc = GameNewInAppPurchasePopViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

    /// 显示升级VIP提示弹窗
    func showInAppPurchasePopView() {
        let vc = GameNewUpgradeVIPViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

    /// 显示错误状态弹窗
    func showErrorStatusVc(title: String?) {
        let vc = OccupyRechargeStatusViewController(status: .fail, title: title)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

    /// 显示网络断开连接弹窗
    func showBadNetworkView() {
        badNetworkPopView = BadNetworkPopView()
        badNetworkPopView.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kScreenHeight)
        badNetworkPopView.isHidden = true
        badNetworkPopView.confirmTapHandle = { [weak self] in
            BugTrackService<UserTrackEvent>.writeEventToFile(event: .BadNetwork)
            self?.leave()
        }
    }

    // MARK: - ViewModel
    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel.roomInfoError
            .subscribe(onNext: { [weak self] env in
                guard let self = self else { return }
                if env.code != "0" {
                    self.badNetworkPopView.type = .machineError
                    self.badNetworkPopView.descLb.text = env.msg
                    if self.badNetworkPopView.isHidden {
                        self.badNetworkPopView.isHidden = false
                    }
                }
            })
            .disposed(by: disposeBag)

        self.viewModel.roomInfo
            .subscribe(onNext: { [weak self] roomInfo in
                self?.titleLb.text = roomInfo.machine?.title
                self?.scrollLabelAnimation()
                self?.tipView.updateText(roomInfo.tip)
                self?.roomInfo = roomInfo
                self?.gameTableView.tableHeaderView = self?.setupHeaderView()
            })
            .disposed(by: disposeBag)

        viewModel.showNDVipWarning
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                self?.showRulePopView()
            })
            .disposed(by: disposeBag)
    }

    func bindNavigationBar() {
        navigationBar.rx.exitButtonTap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.leave()
            })
            .disposed(by: disposeBag)

        navigationBar.rx.questionButtonTap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.switchToFAQ()
            })
            .disposed(by: disposeBag)
    }
}

extension GameNewViewController: UIScrollViewDelegate {

    @objc private func changeScrollstate() {
        canScroll = true
        containerCell?.objectCanScroll = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == gameTableView else { return }

        // 控制navigationBar显示
        var contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY <= 0 { // 下拉
            navigationBar.alpha = 0.0
        } else { // 上拉
            if contentOffsetY >= Constants.kStatusBarHeight {
                contentOffsetY = Constants.kStatusBarHeight
            }
            navigationBar.alpha = contentOffsetY/Constants.kStatusBarHeight
        }

        // 控制悬停
        let sectionViewY = floor(self.gameTableView.rect(forSection: 0).origin.y)
        let y = scrollView.contentOffset.y
        if y >= sectionViewY { // 吸顶
            scrollView.contentOffset = CGPoint(x: 0, y: sectionViewY)
            canScroll = false
            containerCell?.objectCanScroll = true
        } else { // 没吸顶
            if !canScroll {
                scrollView.contentOffset = CGPoint(x: 0, y: sectionViewY)
            }
        }
    }
}

extension GameNewViewController: Rechargable {

    func rechargeSuccess() {
        self.viewModel.refreshBalanceTrigger.onNext(())
    }

    func rechargeFail() {
        // nothing
    }
}

extension GameNewViewController: GameContainerCellDelegate {

    func containerCellScrollViewDidScroll(scrollView: UIScrollView) {
        gameTableView.isScrollEnabled = false
    }

    func containerCellScrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = ceil(scrollView.contentOffset.x / Constants.kScreenWidth )
        sectionView.selectIndex = Int(page)
        gameTableView.isScrollEnabled = true
    }

    func didSelectedGameProductTableviewCell(product: Product) {
        self.navigationController?.pushViewController(GameProductDetailViewController(product: product), animated: true)
    }
}

extension GameNewViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.containerCell {
            return cell
        } else {
            let cell = GameContainerCell(style: .default, reuseIdentifier: nil)
            cell.configureWith(roomId: roomNumber)
            cell.delegate = self
            cell.cv.delegate = self
            self.containerCell = cell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GameContainerCell.CellHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.sectionView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
}

extension GameNewViewController {

    // 从后台回来
    @objc private func willEnterForeground(notification: NSNotification) {

        // 防止其他页面如 充值页面跳转其他应用 回来时触发这个方法
        if self.topMostViewController is GameNewViewController, self.navigationController?.viewControllers.count == 1 {
            dispatch_async_safely_main_queue {
                self.removeOldPlayer()
                self.gameTableView.tableHeaderView = nil
                self.gameTableView.tableHeaderView = self.setupHeaderView()
                self.liveStreamPlayer?.prepareToPlay()
                AudioService.shared.play(audioType: .bgm)
            }
        }
    }

    // 进入后台
    @objc private func willResignActive(notification: NSNotification) {
        dispatch_async_safely_main_queue {
            if let player = self.liveStreamPlayer, player.isPlaying() {
                player.stop()
            }
            AudioService.shared.stop()
        }
    }
}

extension Game.State: StateType {}

extension GameNewViewController: GamePopOverViewDelegate {

    // 再干一次
    private func continuePlaying() {

        guard let orderId = self.orderId else { return }

        SocketService.shared.emitUserPlayGame(param: .restart(roomId: roomNumber, eventId: randomStr, orderId: orderId)) { _ in}
    }

    // 先不来了
    private func cancelPlaying() {

        guard let orderId = self.orderId else { return }

        SocketService.shared.emitUserPlayGame(param: .cancel(roomId: roomNumber, eventId: randomStr, orderId: orderId)) { _ in }

        AudioService.shared.play(audioType: .bgm)
    }

    // 触发霸机充值
    private func occupyRecharge() {

        guard let orderId = self.orderId else { return }

        isMunualRecharge = true

        SocketService.shared.emitUserPlayGame(param: .recharge(roomId: roomNumber, eventId: randomStr, orderId: orderId)) { _ in }
    }

    /// 显示霸机充值界面，
    ///
    /// - Parameter ttl: 剩余时间
    private func showOccupyRechargeViewController(ttl: TimeInterval? = nil) {
        let vc = OccupyRechargeViewController(roomId: roomNumber,
                                              delegate: self,
                                              amount: Int(self.roomInfo?.machinePrice ?? "") ?? 0,
                                              ttl: ttl,
                                              isMunualRecharge: isMunualRecharge)
        vc.rechargeDelegate = self
        self.navigationController?.addChild(vc)
        self.navigationController?.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }

    /// 再来一次
    func viewDidPressedContinueButton() {
        reset()
        continuePlaying()
    }

    /// 不玩了
    func viewDidPressedCancelButton() {
        reset()
        cancelPlaying()
    }

    /// 霸机充值
    func viewDidPressedRechargeButton() {
        reset()
        occupyRecharge()
    }

    /// 超时
    func viewDidTimeout() {
        reset()
    }
}

extension GameNewViewController: OccupyRechargeViewControllerDelegate {

    //
    func willDismissViewController() {
        dispatch_async_safely_main_queue { [weak self] in
            guard let self = self else { return }
            self.removeOldPlayer()
            self.gameTableView.tableHeaderView = nil
            self.gameTableView.tableHeaderView = self.setupHeaderView()
            self.liveStreamPlayer?.prepareToPlay()
            AudioService.shared.play(audioType: .bgm)
        }
    }

    func occupyRechargeViewControllerDidRecharge(status: OccupyRechageStatus) {
        let vc = OccupyRechargeStatusViewController(status: status)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)

        if status == .success {
            finishOccupyRecharge()
        }
    }

    func occupyRechargeViewControllerDidTimeout() {
        cancelOccupyRecharge()
    }

    // 完成霸机
    private func finishOccupyRecharge() {

        guard let orderId = self.orderId else { return }

        SocketService.shared.emitUserPlayGame(param: .finishRecharge(roomId: roomNumber, eventId: randomStr, orderId: orderId)) { _ in }
    }

    // 取消霸机充值
    private func cancelOccupyRecharge() {

        guard let orderId = self.orderId else { return }

        SocketService.shared.emitUserPlayGame(param: .cancelRecharge(roomId: roomNumber, eventId: randomStr, orderId: orderId)) { _ in }
    }
}

extension GameNewViewController: SocketGameReactable, SocketStatusReactable {

    func onReconnect() {
        // 防止展示得太快
        delayOn(1.0) {
            self.badNetworkPopView.type = .badNetwork
            self.badNetworkPopView.isHidden = false
        }
    }

    func onUserRoomUpdated(envelope: UserRoomUpdatedEnvelope) {

        self.statusView.realTimeInfo = envelope.realTimeInfo

        if statusView.playable {
            statusView.snp.remakeConstraints { make in
                make.top.left.equalTo(12)
                make.height.equalTo(36)
                make.width.equalTo(85)
            }
        } else {
            statusView.snp.remakeConstraints { make in
                make.top.left.equalTo(12)
                make.height.equalTo(36)
                make.width.greaterThanOrEqualTo(85)
            }
        }

        self.realTimeInfoView.updatePlayersStatus(players: envelope.realTimeInfo.roomUsers,
                                                  count: envelope.realTimeInfo.clientCount)

        guard let status = envelope.realTimeInfo.status else { return }

        // TODO Add another protocol to constraint realTimeInfo
        switch status {
        case .used, .stop:
            gameIdleButton.disable()
        case .ready:
            gameIdleButton.enable()
            exchangeButton.isHidden = false
            rechargeButton.isHidden = false
            gamePlayingButton.on(state: .win)
        case .unknown: return
        }
    }

    func onGameStatusUpdated(envelope: GameStatusUpdatedEnvelope) {

        self.handleCode(env: envelope)

        self.powerInfo = envelope.powerInfo

        if let state = envelope.gameStatus {

            self.orderId = envelope.orderId

            self.gameIdleButton.on(state: state)
            self.countdownView.on(state: state)
            self.gamePlayingButton.on(state: state)
            self.exchangeButton.on(state: state)

            if state == .ready {
                AudioService.shared.on(state: .ready)
                self.rechargeButton.balance = envelope.balance
                if let ttl = envelope.ttl, let doubleTtl = Double(ttl) {
                    self.startCountdown(from: doubleTtl / 1000)
                }
                self.criticalState = .userStartGame(remainSec: self.gameWillStartInSec)
            } else if state == .go {

                AudioService.shared.on(state: .go)
                self.gamePlayingButton.isEnabled = false
                self.countdownView.finishCountdown()

                if let critMultiple = envelope.critMultiple {
                    criticalState = .fired(usedCrit: critMultiple>0)
                    if critMultiple >= 1 { // 展示暴击状态
                        self.criticalView.playCritingAnimtion(critCount: critMultiple)
                        self.criticalState = .fired(usedCrit: true)
                        self.shakeWindowAnimation()
                    }
                }
            } else if state == .act {
                AudioService.shared.on(state: .act)
            } else if state == .win {
                MainViewController.isEggProductRefresh = true
                self.criticalState = .gameGetResult
                self.popOverView.updateEnvelope(env: envelope)
                self.popOverView.on(state: .win)
            } else if state == .err {
                let errorView = GameErrorView(title: envelope.title, msg: envelope.msg)
                UIApplication.shared.keyWindow?.addSubview(errorView)
                AudioService.shared.on(state: .err)
            } else if state == .recharge {
                if let ttl = envelope.ttl, let doubleTtl = Double(ttl) {
                    showOccupyRechargeViewController(ttl: doubleTtl)
                }
            }
        }

    }
}

extension GameNewViewController: GameNewCriticalViewDelegate {
    func didQuestionClick() {
        if let url = self.powerInfo?.noticeUrl {
            self.navigationController?.pushViewController(WKWebViewController(url: URL(string: url)!, headers: [:]), animated: true)
        }
    }

    func didCanceledCrit() {
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .ActionCancle)
    }

    func didConfirmedCrit(critCount: Int) {
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .ActionConfirm(critCount: critCount))
        usedCritCount = critCount
        useCrit()
    }

    /// 屏幕震动动画
    private func shakeWindowAnimation() {
        UIWindow.animate(withDuration: 0.066, delay: 0, options: [.repeat, .autoreverse], animations: {
            UIWindow.setAnimationRepeatCount(3)

            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.frame.origin = CGPoint(x: 4, y: -4)
            }
        }, completion: { finish in
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.frame.origin = .zero
            }
        })
    }
}
