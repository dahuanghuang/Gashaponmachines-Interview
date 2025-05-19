import UIKit
import AVKit
import Argo

class YFSLivestreamViewController: BaseViewController {
    
    /// 导航条
    var navigationBar = UIView()
    
    // 第几弹
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.with(textColor: .white, boldFontSize: 32)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    /// 滚动视图
    private let scrollView: MulGestureScrollView = {
        let scrollView = MulGestureScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.bounces = false
        return scrollView
    }()
    
    /// 头部视图
    var headerView = UIView()
    
    /// 头部高度
    let headViewHeight = floor((Constants.kScreenWidth - 24) * (4/3) + 112)
    
    /// 直播背景视图
    let liveBgView = UIView.withBackgounrdColor(.clear)
    
    /// 扭蛋机模糊背景图
    lazy var blurBgView: UIImageView = {
        let view = UIImageView.with(imageName: "yfs_ls_loading")
        view.isUserInteractionEnabled = false
        return view
    }()

    /// 跑马灯
    lazy var borderIv: UIView = {
        let view = RoundedCornerView(corners: [.topLeft], radius: 12, backgroundColor: .clear)
        view.layer.borderWidth = 8
        view.layer.borderColor = UIColor.new_yellow.cgColor
        return view
    }()
    
    /// 左上角状态视图
    lazy var statusView = YiFanShangLivestreamStatusView()
    
    /// 右上角用户
    lazy var realTimeInfoView = YFSLiveLookUserView()
    
    /// 奖品视图
    var rewardView: YiFanShangLivestreamRewardView?

    /// 等待背景视图
    var waitingBgView = UIView()

    /// 底部遮罩视图
    var bottomImageView = UIImageView()
    
    /// 等待中视图
    lazy var infoWaitingView = YiFanShangLivestreamInfoWaitingView()

    /// 开赏视图
    lazy var infoPlayingView = YiFanShangLivestreamInfoPlayingView()

    /// 返回详情按钮
    lazy var backDetailButton: UIButton = UIButton.with(imageName: "yfs_ls_back")
    
    /// 错误弹窗
    let errorView = YSFLiveErrorView()

    /// 直播播放器
    var liveStreamPlayer: GameMoviePlayerController?

    /// 视频录像播放器
    var videoPlayer: AVPlayerViewController!
    
    /// 播放录像视图
    var playVideoView = UIView()

    /// 播放录像按钮
    lazy var playVideoButton: UIButton = {
        let image = UIImage(named: "yfs_play_button")
        let btn = UIButton(type: .custom)
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(playVideoAction), for: .touchUpInside)
        return btn
    }()

    /// 录像提示Label
    lazy var videoTipLabel = UILabel.with(textColor: .white, fontSize: 24)

    /// 录播视频地址
    var videoAddress: String?

    /// 赏信息
    var eggInfos = [YiFanShangLivestreamInfo.LiveEggInfo]()

    /// 是否已经故障过
    var isErrored: Bool = false

    /// 直播地址
    var liveAddress: String?

    /// 当前展示的视图
    var currentIndex: Int = 0

    /// 底部的选择视图
    lazy var segmentView: YiFanShangLivestreamSegmentView = {
        let view = YiFanShangLivestreamSegmentView()
        view.allRecordTapCallBack = { [weak self] in
            guard let self = self else { return }
            self.currentIndex = 0
            self.showChildViewController(at: self.currentIndex)
        }
        view.myRecordTapCallBack = { [weak self] in
            guard let self = self else { return }
            self.currentIndex = 1
            self.showChildViewController(at: self.currentIndex)
        }
        return view
    }()

    /// 标记`scrollView`是否可以滚动
    var isScrollViewCanScroll = true

    /// 用于左右滑动切换控制器
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 10.0])

    /// 全部记录控制器
    let totalRecordVc = YFSLiveUserRecordViewController()

    /// 我的记录控制器
    let myRecordVc = YFSLiveUserRecordViewController()

    /// 控制器
    var viewControllers: [YFSLiveUserRecordViewController] = []

    /// 房间ID
    var roomId: String?

    /// 重连弹框
    private lazy var reconnectingView = IndexReconnectingView()

    /// 更改赏图片数据
    func replaceRecordsAwardImage(records: [YiFanShangLiveStreamRecord]) -> [YiFanShangLiveStreamRecord] {
        var nweRecords = [YiFanShangLiveStreamRecord]()
        for record in records {
            var r = record
            for info in self.eggInfos {
                if record.awardType == info.eggType {
                    r.imageUrl = info.eggAwardSmallIcon
                }
            }
            nweRecords.append(r)
        }
        return nweRecords
    }

    /// 房间信息
    var livestreamInfo: YiFanShangLivestreamInfo? {
        didSet {

            // 赏显示
            if let eggInfos = livestreamInfo?.eggInfo {
                self.eggInfos = eggInfos
                self.setupRewardInfoView(eggInfos: eggInfos)
            }

            // 用户列表
            if let yfsRecords = livestreamInfo?.yfsRecord {
                var totalRecords = [YiFanShangLiveStreamRecord]()
                // 合并一番赏和魔法阵的券
                for yfsRecord in yfsRecords {
                    totalRecords.append(yfsRecord)

                    if let magicRecords = livestreamInfo?.magicRecord {
                        for magicRecord in magicRecords {
                            if magicRecord.number == yfsRecord.number {
                                totalRecords.append(magicRecord)
                            }
                        }
                    }
                }

                // 更改赏图片数据
                self.totalRecords = replaceRecordsAwardImage(records: totalRecords)

                // 找到我的记录
                var myRecords = [YiFanShangLiveStreamRecord]()
                for record in self.totalRecords {
                    if record.userId == AppEnvironment.userId {
                        myRecords.append(record)
                    }
                }
                self.myRecords = myRecords
            }

            // 录像地址
            if let videoAddress = livestreamInfo?.videoAddress {
                self.videoAddress = videoAddress
            }

            // 状态
            if let statusInfo = livestreamInfo?.statusInfo {
                self.statusView.configureWith(statusInfo: statusInfo)
                self.statusView.readyPlayCallback = { [weak self] in
                    if statusInfo.status == .livePlaying {
                        self?.showInfoPlayingView()
                    }
                }
                self.status = statusInfo.status ?? .onSale
            }

            // 第几弹
            if let serial = livestreamInfo?.serial {
                titleLabel.text = "第\(serial)弹"
            }

            // 当前房间人数总数
            if let users = livestreamInfo?.roomUsers,
                let clientCount = livestreamInfo?.clientCount,
                let count = Int(clientCount) {
                self.realTimeInfoView.updatePlayersStatus(players: users, count: count)
            }

            // 直播地址
            if let liveAddress = livestreamInfo?.liveAddress {
                self.liveAddress = liveAddress
                self.addPlayerView(liveAddress: liveAddress)
            }

            // 震动(一定会有)
            if let awardInfo = livestreamInfo?.awardInfo, let userId =  AppEnvironment.userId {
                if awardInfo.userId == userId {
                    let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
                    if Setting.vibrate.isEnabled {
                        AudioServicesPlaySystemSound(vibrate)
                    }
                }
            }

            // 开赏信息
            if let centerNotice = livestreamInfo?.centerNotice, centerNotice.awardType != "0" {

                // id不同,不为同一期开赏结果
                if let currentRoomdId = self.roomId, let gameId = centerNotice.gameId, currentRoomdId != gameId { return }

                // 爆奖音(需要关闭静音)
                if centerNotice.awardType == "101" ||
                    centerNotice.awardType == "102" ||
                    centerNotice.awardType == "103" {
                    if let path = Bundle.main.path(forResource: "winning", ofType: "aac") {
                        var soundID: SystemSoundID = 0
                        AudioServicesCreateSystemSoundID(URL(fileURLWithPath: path) as CFURL, &soundID)
                        if Setting.music.isEnabled {
                            AudioServicesPlaySystemSound(soundID)
                        }
                    }
                }

                // 更新开赏视图
                let imageUrl = findAwardImageUrl(type: centerNotice.awardType, isSmall: false)
                self.infoPlayingView.updateInfoPlayingView(centerNotice: centerNotice, awardImageUrl: imageUrl)
                self.infoPlayingView.hideCallback = { [weak self] in
                    self?.hideInfoPlayingView()
                }

                // 更新底部用户列表
                updateUserRecords(livestreamInfo: livestreamInfo)
            }
        }
    }

    /// 直播状态
    var status: YiFanShangStatus = .onSale {
        didSet {
            switch status {
            case .onSale:
                self.infoWaitingView.tipLabel.text = "售卖中"
            case .waitMachine:
                self.infoWaitingView.tipLabel.text = "等待机台"
            case .livePlaying:
                self.playBgm()
                self.realTimeInfoView.isHidden = false
                self.infoWaitingView.tipLabel.text = ""
            case .liveFinish:
                AudioHelper.shared.stop()
                self.realTimeInfoView.isHidden = true
                self.removeOldPlayer()
                self.infoWaitingView.tipLabel.text = "- 已结束 -"
                self.addPlayVideoView()
                self.videoTipLabel.text = "视频上传中..."
                self.playVideoButton.isEnabled = false
            case .error:
                self.infoWaitingView.tipLabel.text = "机器意外暂停, 修复后继续运行"
                if !self.isErrored { // 还没有出现故障
                    self.isErrored = true
                    errorView.show()
                }
            case .videoFinish:
                self.infoWaitingView.tipLabel.text = "- 已结束 -"
                self.addPlayVideoView()
                self.videoTipLabel.text = "查看录像"
                self.playVideoButton.isEnabled = true
            }
        }
    }

    /// 更新房间长链接事件
    var updateEnvelope: YiFanShangLivestreamListenEnvelope? {
        didSet {
            livestreamInfo = updateEnvelope?.onePieceInfo
        }
    }

    /// 加入房间长链接事件
    var JoinRoomEnvelope: YiFanShangLivestreamEnvelope? {
        didSet {
            livestreamInfo = JoinRoomEnvelope?.data
        }
    }

    /// 我的购买记录
    var myRecords: [YiFanShangLiveStreamRecord] = [] {
        didSet {
            self.myRecordVc.updateData(records: myRecords)
            self.segmentView.myRecordsCount = myRecords.count
            if myRecords.count > 0 {
                self.myRecordVc.emptyView.isHidden = true
            }
        }
    }

    /// 全部购买记录
    var totalRecords: [YiFanShangLiveStreamRecord] = [] {
        didSet {
            self.totalRecordVc.updateData(records: totalRecords)
            if totalRecords.count > 0 {
                self.totalRecordVc.emptyView.isHidden = true
            }
        }
    }

    // MARK: - 初始化方法
    init(roomId: String) {
        super.init(nibName: nil, bundle: nil)
        self.roomId = roomId
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "FF7C74")

        setupNotification()
        
        setupUI()

        setupHeaderView()

        setupReconnectingView()
        
        requestData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        SocketService.shared.statusHandler = self

        if let liveAddress = self.liveAddress {
            self.addPlayerView(liveAddress: liveAddress)
        }
        
        if self.status == .livePlaying {
            self.playBgm()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let id = roomId {
            SocketService.shared.emitEvent(.leaveOnePieceRoom(onePieceTaskId: id)) { data in }
        }
        removeOldPlayer()
        AudioHelper.shared.stop()
    }

    /// 初始化通知
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(scrollStateNotification(_:)), name: .userCenterScrollState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func setupUI() {
        
        let bgIv = UIImageView(image: UIImage(named: "yfs_live_background"))
        view.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + 280)
        }
        
        navigationBar.backgroundColor = .clear
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
        }
        
        // 退出按钮
        let quitButton = UIButton.with(imageName: "yfs_live_back")
        quitButton.addTarget(self, action: #selector(quit), for: .touchUpInside)
        navigationBar.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        // 标题
        navigationBar.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 滚动视图
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    func setupHeaderView() {

        // 头部
        headerView.backgroundColor = .clear
        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.width.equalTo(view)
            make.height.equalTo(headViewHeight)
        }

        // 直播背景视图
        headerView.addSubview(liveBgView)
        liveBgView.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo((Constants.kScreenWidth - 24) * (4/3))
        }

        // 模糊图
        liveBgView.addSubview(blurBgView)
        blurBgView.snp.makeConstraints { make in
            make.top.left.equalTo(8)
            make.right.bottom.equalTo(-8)
        }

        // 跑马灯边框
        borderIv.isUserInteractionEnabled = true
        headerView.addSubview(borderIv)
        borderIv.snp.makeConstraints { make in
            make.edges.equalTo(liveBgView)
        }
        
        // 右上角图片
        let topLogoIv = UIImageView(image: UIImage(named: "yfs_live_header"))
        headerView.addSubview(topLogoIv)
        topLogoIv.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalTo(borderIv)
            make.width.equalTo(154)
            make.height.equalTo(20)
        }

        // 左上角状态
        borderIv.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
            make.height.equalTo(36)
            make.width.greaterThanOrEqualTo(85)
        }

        // 观众
        borderIv.addSubview(realTimeInfoView)
        realTimeInfoView.isHidden = true
        realTimeInfoView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(statusView)
            make.width.equalTo(220)
            make.height.equalTo(36)
        }

        // 等待背景视图
        waitingBgView.backgroundColor = .clear
        headerView.addSubview(waitingBgView)
        waitingBgView.snp.makeConstraints { (make) in
            make.top.equalTo(liveBgView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }

        // 等待视图
        waitingBgView.addSubview(infoWaitingView)
        infoWaitingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 底部遮罩视图
        bottomImageView.image = UIImage(named: "yfs_waiting_bg_bottom")
        waitingBgView.addSubview(bottomImageView)
        bottomImageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }

        // 开赏
        waitingBgView.insertSubview(infoPlayingView, belowSubview: bottomImageView)
        infoPlayingView.snp.makeConstraints { make in
            make.width.equalTo(Constants.kScreenWidth - 44)
            make.height.equalTo(52)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomImageView.snp.top).offset(52)
        }

        // 选择视图
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { (make) in
            make.centerX.width.equalTo(view)
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(YiFanShangLivestreamSegmentView.height)
        }

        // pageVc
        viewControllers.append(totalRecordVc)
        viewControllers.append(myRecordVc)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        scrollView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(segmentView.snp.bottom)
            make.bottom.equalTo(scrollView)
            make.centerX.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(scrollView).offset(-YiFanShangLivestreamSegmentView.height)
        }
        pageViewController.didMove(toParent: self)
        showChildViewController(at: currentIndex)

        // 返回详情按钮
        let staBarH = UIApplication.shared.statusBarFrame.height
        let navBarH = self.navigationController?.navigationBar.height ?? 0
        backDetailButton.addTarget(self, action: #selector(backDetailVc), for: .touchUpInside)
        view.addSubview(backDetailButton)
        backDetailButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 112/2, height: 96/2))
            make.top.equalTo(staBarH + navBarH + 63)
            make.left.equalToSuperview()
        }
    }

    func setupRewardInfoView(eggInfos: [YiFanShangLivestreamInfo.LiveEggInfo]) {
        if self.rewardView == nil {
            // 头部 + 所有赏高度 + 尾部
            let height = 41 + 28 * eggInfos.count
            let view = YiFanShangLivestreamRewardView(eggInfos: eggInfos)
            headerView.addSubview(view)
            view.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-24)
                make.width.equalTo(78)
                make.height.equalTo(height)
                make.centerY.equalTo(borderIv)
            }
            self.rewardView = view
        }
    }

    func setupReconnectingView() {
        view.addSubview(reconnectingView)

        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        }

        reconnectingView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(-bottomPadding-12)
            make.width.equalTo(498/2)
            make.height.equalTo(48)
        }
    }

    /// 请求数据
    func requestData() {
        // 加入房间
        if let roomId = roomId {
            SocketService.shared.emitEvent(.joinOnePieceRoom(onePieceTaskId: roomId)) { [weak self] data in
                guard let self = self else { return }

                guard let real = data.first, JSONSerialization.isValidJSONObject(real) else {
                    QLog.error("Invalid json data returned from server.")
                    return
                }

                if let jsonObject: Any = data.first, let envelope: YiFanShangLivestreamEnvelope = decode(jsonObject) {
                    if AppDelegate.enabledLog {
                        let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
                        if let jData = jsonData {
                            let jsonStr = String(data: jData, encoding: String.Encoding.utf8)
                            print("joinOnePieceRoom------------=======>>>>", jsonStr?.toJSON())
                        }
                    }
                    self.JoinRoomEnvelope = envelope
                } else {
                    QLog.error("解析 YiFanShangLivestreamEnvelope 出错")
                }
            }
        }

        // 更新房间
        SocketService.shared.onEvent(.onePieceRoomUpdate, callback: { [weak self] (data, ack) in
            guard let self = self else { return }

            guard let real = data.first, JSONSerialization.isValidJSONObject(real) else {
                QLog.error("Invalid json data returned from server.")
                return
            }
            if let j: Any = data.first, let envelope: YiFanShangLivestreamListenEnvelope = decode(j) {
                self.updateEnvelope = envelope
            } else {
                QLog.error("解析 YiFanShangLivestreamListenEnvelope 出错")
            }
        })
    }

    // MARK: - 自定义方法
    // 更新底部用户信息
    func updateUserRecords(livestreamInfo: YiFanShangLivestreamInfo?) {

        if let number = livestreamInfo?.awardInfo?.number {
            // 拆分正在开赏的券
            var removeTotalRecords = [YiFanShangLiveStreamRecord]()
            var removeMyRecords = [YiFanShangLiveStreamRecord]()

            removeTotalRecords = totalRecords.filter { (record) -> Bool in
                return record.number == number
            }
            removeMyRecords = myRecords.filter { (record) -> Bool in
                return record.number == number
            }

            totalRecords = totalRecords.filter { (record) -> Bool in
                return record.number != number
            }
            myRecords = myRecords.filter { (record) -> Bool in
                return record.number != number
            }

            // 更换开赏图标
            let imageUrl = findAwardImageUrl(type: livestreamInfo?.awardInfo?.awardType, isSmall: true)
            removeTotalRecords = removeTotalRecords.map { (record) -> YiFanShangLiveStreamRecord in
                var r = record
                r.imageUrl = imageUrl
                r.awardType = livestreamInfo?.awardInfo?.awardType
                return r
            }
            removeMyRecords = removeMyRecords.map { (record) -> YiFanShangLiveStreamRecord in
                var r = record
                r.imageUrl = imageUrl
                r.awardType = livestreamInfo?.awardInfo?.awardType
                return r
            }

            // 移动到最上面展示
            totalRecords = removeTotalRecords + totalRecords
            myRecords = removeMyRecords + myRecords

            // 更新数据
            self.totalRecordVc.updateData(records: totalRecords)
            self.myRecordVc.updateData(records: myRecords)
        }
    }

    /// 寻找当前type对应的图片
    func findAwardImageUrl(type: String?, isSmall: Bool) -> String? {
        var awardImageUrl: String?
        for info in self.eggInfos {
            if type == info.eggType {
                awardImageUrl = isSmall ? info.eggAwardSmallIcon : info.eggAwardBigIcon
            }
        }
        return awardImageUrl
    }

    /// 展示子控制器
    func showChildViewController(at index: Int) {
        if index >= viewControllers.count || index < 0 {
            return
        }
        var currentIndex = 0
        if let currentVC = pageViewController.viewControllers?.last as? YFSLiveUserRecordViewController,
            let idx = viewControllers.index(of: currentVC) {
            currentIndex = idx
        }
        let toVC = viewControllers[index]
        let direction: UIPageViewController.NavigationDirection = (currentIndex > index) ? .reverse : .forward
        pageViewController.setViewControllers([toVC], direction: direction, animated: true, completion: nil)
    }

    /// 滚动状态监听
    @objc private func scrollStateNotification(_ sender: Notification) {
        isScrollViewCanScroll = true
        viewControllers.forEach { $0.isCanContentScroll = false }
    }

    /// 显示开赏记录
    func showInfoPlayingView() {

        if self.status != .livePlaying {
            return
        }

        // 显示当前回合
        let records = totalRecords.filter { (record) -> Bool in
            return record.awardType == ""
        }
        if let currentRecord = records.first {
            infoPlayingView.record = currentRecord
        }

        // 开始动画
        infoPlayingView.isHidden = false

        self.infoPlayingView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.bottomImageView.snp.top).offset(0)
        }

        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.waitingBgView.layoutIfNeeded()
        }, completion: { _ in
            self.waitingBgView.insertSubview(self.bottomImageView, belowSubview: self.infoPlayingView)

            if self.status != .livePlaying {
                self.hideInfoPlayingView()
            }
        })
    }

    /// 隐藏开赏记录
    func hideInfoPlayingView() {
        // 上移
        self.infoPlayingView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.bottomImageView.snp.top).offset(-20)
        }

        UIView.animate(withDuration: 0.17) {
            self.waitingBgView.layoutIfNeeded()
        }

        // 下移
        self.infoPlayingView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.bottomImageView.snp.top).offset(self.bottomImageView.height)
        }

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.waitingBgView.layoutIfNeeded()
        }, completion: { _ in
            self.infoPlayingView.isHidden = true
            self.waitingBgView.insertSubview(self.infoPlayingView, belowSubview: self.bottomImageView)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if self.status == .livePlaying {
                    self.showInfoPlayingView()
                }
            })
        })
    }

    /// 添加播放录像视图
    func addPlayVideoView() {

        if headerView.subviews.contains(playVideoView) {
            return
        }

        // 背景
        playVideoView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        blurBgView.addSubview(playVideoView)
        playVideoView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        // 播放按钮
        borderIv.addSubview(playVideoButton)
        playVideoButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(60)
        }

        // 描述文字
        borderIv.addSubview(videoTipLabel)
        videoTipLabel.snp.makeConstraints { make in
            make.top.equalTo(playVideoButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }

    /// 播放录像
    @objc func playVideoAction() {

        //        guard let url = URL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4") else {
        //            return
        //        }

        guard let videoAddress = self.videoAddress, let url = URL(string: videoAddress) else {
            HUD.showError(second: 1.0, text: "录像出错", completion: nil)
            return
        }

        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
//        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }

    /// 退出
    @objc func quit() {

        AudioHelper.shared.stop()

        if let id = roomId {
            SocketService.shared.emitEvent(.leaveOnePieceRoom(onePieceTaskId: id)) { data in }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    /// 返回详情界面
    @objc func backDetailVc() {

        AudioHelper.shared.stop()

        if let id = roomId {
            SocketService.shared.emitEvent(.leaveOnePieceRoom(onePieceTaskId: id)) { data in }

            if let vcs = self.navigationController?.viewControllers {
                var detailVc: YiFanShangDetailViewController?
                for vc in vcs {
                    if vc.isKind(of: YiFanShangDetailViewController.self) {
                        detailVc = vc as? YiFanShangDetailViewController
                    }
                }

                if let vc = detailVc {
                    self.navigationController?.popToViewController(vc, animated: true)
                } else {
                    let detailVc = YiFanShangDetailViewController(recordId: id)
                    self.navigationController?.pushViewController(detailVc, animated: true)
                }
            }
        }
    }

    /// 开始直播
    func addPlayerView(liveAddress: String) {
        if self.liveStreamPlayer != nil { return }

        self.liveStreamPlayer = GameMoviePlayerController(contentURLString: liveAddress)!
        self.liveStreamPlayer?.scalingMode = .fill
        self.liveStreamPlayer?.prepareToPlay()
        if let player = self.liveStreamPlayer {
            liveBgView.addSubview(player.view)
            if player.view.superview != nil {
                player.view.snp.makeConstraints { make in
                    make.edges.equalTo(blurBgView)
                }
            }
        }
    }

    /// 关闭直播
    func removeOldPlayer() {
        self.liveStreamPlayer?.stop()
        self.liveStreamPlayer?.shutdown()
        self.liveStreamPlayer?.view.removeFromSuperview()
        self.liveStreamPlayer = nil
    }

    /// 循环播放背景音
    func playBgm() {
        if AudioHelper.shared.isPlaying {
            return
        }

        var names = [String]()
        for i in 1...5 {
            names.append("yfs\(i).mp3")
        }
        AudioHelper.shared.playRandomAudio(names: names)
    }
}

extension YFSLivestreamViewController: SocketStatusReactable {

    func onReconnect() {
        reconnectingView.show()
    }

    func onConnected() {
        // 隐藏弹框
        reconnectingView.hide()
        // 重新加入房间
        self.requestData()
    }
}

extension YFSLivestreamViewController: UIPageViewControllerDataSource {

    /// 返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewControllers.count == 0 { return nil }
        guard
            let proxyVC = viewController as? YFSLiveUserRecordViewController,
            let index = viewControllers.index(of: proxyVC)
            else { return nil }
        if index < viewControllers.count - 1 {
            return viewControllers[index+1]
        }
        return nil
    }

    /// 返回当前页面的上一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewControllers.count == 0 { return nil }
        guard
            let proxyVC = viewController as? YFSLiveUserRecordViewController,
            let index = viewControllers.index(of: proxyVC)
            else { return nil }
        if index > 0 {
            return viewControllers[index-1]
        }
        return nil
    }
}

extension YFSLivestreamViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let currentVC = pageViewController.viewControllers?.last as? YFSLiveUserRecordViewController,
            let index = viewControllers.index(of: currentVC)
            else { return }
        self.currentIndex = index
        segmentView.setIndicatorLocation(at: index)
    }
}

extension YFSLivestreamViewController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        viewControllers.forEach { $0.scrollToTop() }
        return true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if totalRecords.count == 0 ||
            (currentIndex == 1 && self.myRecords.count == 0) {
            return
        }

        if scrollView.contentOffset.y >= headViewHeight { // 吸顶
            scrollView.setContentOffset(CGPoint(x: 0.0, y: headViewHeight), animated: false)
            isScrollViewCanScroll = false
            viewControllers.forEach { $0.isCanContentScroll = true }
        } else {
            if !isScrollViewCanScroll {
                scrollView.setContentOffset(CGPoint(x: 0.0, y: headViewHeight), animated: false)
            }
        }
    }
}

extension YFSLivestreamViewController {
    /// 从后台回来监听
    @objc private func willEnterForeground(notification: NSNotification) {
        dispatch_async_safely_main_queue {
            if let liveAddress = self.liveAddress {
                self.addPlayerView(liveAddress: liveAddress)
            }
        }
    }

    /// 进入后台监听
    @objc private func willResignActive(notification: NSNotification) {
        dispatch_async_safely_main_queue {
            self.removeOldPlayer()
            AudioHelper.shared.stop()
        }
    }
}

/// 多手势滚动视图
private class MulGestureScrollView: UIScrollView, UIGestureRecognizerDelegate {

    /// 允许同时识别多个手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
