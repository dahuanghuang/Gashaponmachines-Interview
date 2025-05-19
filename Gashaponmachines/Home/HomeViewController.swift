import UIKit
import Argo
import Alamofire
import Kingfisher

let VersionUpdateNoticeKey = "VersionUpdateNoticeKey"

class HomeViewController: BaseViewController {

    let viewModel = HomeViewModel()

    /// 首页标签数据
    var machineTagEnvelope: HomeMachineTagEnvelope?

    /// 首页弹窗数据
    var popupMenusEnvelope: PopupMenusEnvelope?

    /// 加载中视图
    let loadingView = HomeLoadingView()

    /// 重连视图
    let homeReconnectView = HomeReconnectionView()

    /// socket重连视图
    lazy var socketReconnectView = IndexReconnectingView()

    // 顶部背景图z
    let topBgIv = UIImageView(image: UIImage(named: "home_top_bg_1"))
    
    // 显示隐藏整体动画背景
    let animationContanier = UIView.withBackgounrdColor(.clear)
    
    /// 顶部搜索条
    lazy var searchBar: HomeSearchView = {
        let s = HomeSearchView()
        s.searchButtonClickHandle = { [weak self] in
            self?.jumpToSearchVc()
        }
        return s
    }()

    /// 标题视图
    lazy var titleView: HomeTitleView = {
        let view = HomeTitleView()
        view.delegate = self
        return view
    }()

    /// 子控制器view的bgview
    let childBgView = UIView.withBackgounrdColor(.clear)

    /// 子控制器
    var viewControllers: [UIViewController] = []

    /// 用于左右滑动切换控制器
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 10.0])

    /// 返回机台按钮
    lazy var backGameButton: IndexBackCurrentGameButton = {
        let safeAreaTop: CGFloat
        if #available(iOS 11.0, *) {
            safeAreaTop = view.safeAreaInsets.top
        } else {
            safeAreaTop = topLayoutGuide.length
        }
        let btn = IndexBackCurrentGameButton(frame: CGRect(x: Constants.kScreenWidth, y: 32 + safeAreaTop, width: 398/2, height: 166/2))
        btn.addTarget(self, action: #selector(backGameNewVC), for: .touchUpInside)
        return btn
    }()

    /// 机台ID(适配老版本)
    var physicId: String?
    /// 机台类型(适配老版本)
    var type: MachineColorType?

    // 是否打开过新手弹窗
    var isOpenedQuest: Bool = false

    // 是否打开过签到弹窗
    var isOpenedSign: Bool = false

    // MARK: - 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .new_backgroundColor
        
        setupUI()

        addNotification()

        setupLoadingView()

        setupReconnectView()

        viewModel.requestMachineTags.onNext(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        SocketService.shared.statusHandler = self
        DanmakuService.shared.alertDelegate = self

        if let token = AppEnvironment.current.apiService.accessToken {
            if SocketService.shared.status != .connected {
                SocketService.shared.setupWithSessionToken(sessionToken: token)
                SocketService.shared.connect()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showBackCurrentGameButtonIfNeed()

        continueToShow()
    }

    // MARK: - 初始化函数
    func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func setupReconnectView() {
        homeReconnectView.isHidden = true
        view.addSubview(homeReconnectView)
        homeReconnectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        homeReconnectView.reconnectHandle = { [weak self] in
            self?.loadingView.isHidden = false
            self?.homeReconnectView.isHidden = true
            self?.viewModel.requestMachineTags.onNext(())
        }

        view.addSubview(socketReconnectView)
        let offset = DeviceType.IS_IPHONE_5 ? -49 : 0
        socketReconnectView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-12+offset)
            make.width.equalTo(498/2)
            make.height.equalTo(48)
        }
    }

    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideSearchBar), name: .HomeContentPullUpScroll, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSearchBar), name: .HomeContentPullDownScroll, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(continueToShow), name: .AdPopupMenuClose, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSignSuccess), name: .HomeSignInSuccess, object: nil)
    }
    
    func setupUI() {
        topBgIv.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kStatusBarHeight + 88)
        view.addSubview(topBgIv)
        
        animationContanier.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kStatusBarHeight + 88)
        view.addSubview(animationContanier)
        
        searchBar.frame = CGRect(x: 0, y: Constants.kStatusBarHeight, width: Constants.kScreenWidth, height: 44)
        animationContanier.addSubview(searchBar)
        
        titleView.frame = CGRect(x: 0, y: Constants.kStatusBarHeight + 44, width: Constants.kScreenWidth, height: 44)
        animationContanier.addSubview(titleView)
        
        view.insertSubview(childBgView, belowSubview: topBgIv)
        childBgView.snp.makeConstraints { (make) in
            make.top.equalTo(Constants.kStatusBarHeight + 44)
            make.left.right.bottom.equalToSuperview()
        }
    }

    func setupChildVc() {

        if let env = machineTagEnvelope {
            viewControllers.append(HomeRecommendViewController())
            viewControllers.append(HomeMachineListViewController(style: .all, machineTypes: env.machineTypeList))
            for machineTag in env.machineTagList {
                viewControllers.append(HomeMachineListViewController(style: .other, machineTag: machineTag))
            }
        }

        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        childBgView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        
        // 默认展示第一个
        showChildViewController(at: 0)
    }

    /// 展示子控制器
    func showChildViewController(at index: Int) {
        if index >= viewControllers.count || index < 0 {
            return
        }
        // 找出当前视图
        var currentIndex = 0
        if let currentVC = pageViewController.viewControllers?.last,
            let idx = viewControllers.index(of: currentVC) {
            currentIndex = idx
        }
        
        // 移动到目标视图
        let toVC = viewControllers[index]
        let direction: UIPageViewController.NavigationDirection = (currentIndex > index) ? .reverse : .forward
        pageViewController.setViewControllers([toVC], direction: direction, animated: true, completion: nil)
    }

    /// 展示返回机台视图
    func showBackCurrentGameButtonIfNeed() {
        SocketService.shared.emitEvent(.userGetLastRoom) { [weak self] data in
            guard let real = data.first, JSONSerialization.isValidJSONObject(real) else {
                QLog.error("Invalid json data returned from server.")
                return
            }
            if let j: Any = data.first, let envelope: UserLastRoomEnvelope = decode(j) {
                self?.physicId = envelope.physicId
                self?.type = envelope.type
                self?.setupBackGameButtonView(physicId: envelope.physicId, type: envelope.type)
            }
        }
    }

    func setupBackGameButtonView(physicId: String, type: MachineColorType) {
        // 添加按钮
        let safeAreaTop: CGFloat
        if #available(iOS 11.0, *) {
            safeAreaTop = view.safeAreaInsets.top
        } else {
            safeAreaTop = topLayoutGuide.length
        }
        backGameButton.frame = CGRect(x: Constants.kScreenWidth, y: 32 + safeAreaTop, width: 199, height: 133)
        UIApplication.shared.keyWindow?.addSubview(backGameButton)

        // 动画展示按钮
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut,
        animations: {
            self.backGameButton.frame.origin.x = Constants.kScreenWidth - self.backGameButton.frame.size.width
        },
        completion: { _ in
            delay(6) {
                self.backGameButton.frame = CGRect(x: Constants.kScreenWidth, y: 32 + safeAreaTop, width: 199, height: 133)
            }
        })
    }

    // MARK: - 监听函数
    // 跳转到搜索页面
    func jumpToSearchVc() {
        // 登录界面
        guard AppEnvironment.current.apiService.accessToken != nil else {
            let vc = LoginViewController.controller
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            return
        }

        // 搜索
        if let placeholder = machineTagEnvelope?.searchInfo.placeholder,
            let keywords = machineTagEnvelope?.searchInfo.hotKeywords {
            let searchVc = SearchViewController(placeholder: placeholder, keywords: keywords)
            navigationController?.pushViewController(searchVc, animated: false)
        }
    }
    
    /// 隐藏搜索栏
    @objc func hideSearchBar() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.topBgIv.top = -44
            self.animationContanier.top = -44
            self.animationContanier.backgroundColor = .white
            self.searchBar.alpha = 0.0
        }, completion: nil)
    }

    /// 显示搜索栏
    @objc func showSearchBar() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.topBgIv.top = 0
            self.animationContanier.top = 0
            self.animationContanier.backgroundColor = .clear
            self.searchBar.alpha = 1.0
        }, completion: nil)
    }

    /// 一键返回机台
    @objc func backGameNewVC() {
        if let id = self.physicId, let type = self.type {
            let gameVc = GameNewViewController(physicId: id, type: type)
            gameVc.isBackGame = true
            let vc = NavigationController(rootViewController: gameVc)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

    /// 继续展示 "新手"或 "签到"
    @objc func continueToShow() {
        guard let env = self.popupMenusEnvelope else { return }

        if env.questInfo.mainImage != nil && !self.isOpenedQuest { // 需要展示"新手", 且没有展示过
            showQuestPopMenu()
        } else { // 不需要展示"新手" 或 没有展示过
            if env.signInfo.mainImage != nil && !isOpenedSign { // 需要展示"签到", 且没有展示过
                showSignPopMenu()
            } else {
                showUserGuidePopVc()
            }
        }
    }

    // 显示签到成功
    @objc func showSignSuccess() {
        let vc = StatusPopViewController(tip: "签到成功!", imageName: "home_sign_success")
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: - 自定义函数
    /// 滚动到目标控制器
    func scrollToPointVc(indexPath: IndexPath) {
        self.titleView.scrollToItem(indexPath: indexPath)
        self.showSearchBar()
    }

    func updateVersion() {
        guard let config = AppEnvironment.current.config else {
            return
        }

        let lastDate = UserDefaults.standard.object(forKey: VersionUpdateNoticeKey)
        if let date = lastDate { // 非第一次启动

            let appVersion = DeviceInfo.getAppVersion()

            let isSameDay = Calendar.current.isDate(date as! Date, equalTo: Date(), toGranularity: .day)

            // 当前版本小于线上版本 && 不在审核期间 && 距离上次提示不在同一天
            if appVersion.isOlder(than: config.latestVersion) && !config.isReal && !isSameDay {
                // 展示
                showVersionUpdatePopVc()
                // 保存时间
                UserDefaults.standard.setValue(Date(), forKey: VersionUpdateNoticeKey)
                UserDefaults.standard.synchronize()
            } else {
                viewModel.requestPopupMenus.onNext(())
            }
        } else { // 第一次启动
            UserDefaults.standard.setValue(Date(), forKey: VersionUpdateNoticeKey)
            UserDefaults.standard.synchronize()
        }
    }

    /// 展示新手引导弹窗
    func showUserGuidePopVc() {
        if AppEnvironment.current.apiService.accessToken != nil {
            let showDate = UserDefaults.standard.object(forKey: NewUserGuideHomeDetailKey)
            if showDate == nil && !AppEnvironment.isReal && AppEnvironment.stage == .release { // 第一次展示 && 非审核 && 正式环境
                let vc = NewUserGuidePopViewController(guideType: .home)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    /// 展示版本更新弹窗
    func showVersionUpdatePopVc() {
        let vc = VersionUpdatePopViewController()
        vc.cancelClickHandle = { [weak self] in
            self?.viewModel.requestPopupMenus.onNext(())
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }

    /// 运营弹窗
    func showAdPopMenu(isFirstLanch: Bool) {
        guard let env = self.popupMenusEnvelope else { return }

        // 是否包含首页运营弹窗
        var isContainMain = false

        for adInfo in env.adInfo {
            if adInfo.showPage == .Main {
                if isFirstLanch {
                    showAlert(launchscreen: adInfo)
                    AppEnvironment.userDefault.set(Date(), forKey: PopMenuAdInfoUserDefaultKey + "-" + PopMenuAdInfo.ShowPage.Main.rawValue)
                    AppEnvironment.userDefault.synchronize()
                } else {
                    DanmakuService.shared.showAlert(type: .Main)
                }
                isContainMain = true
            }
        }

        // 没有首页运营弹窗时
        if !isContainMain {
            continueToShow()
        }
    }

    /// 新手弹窗
    func showQuestPopMenu() {
        guard let env = self.popupMenusEnvelope else { return }

//        if let mainImage = env.questInfo.mainImage {
//            ImageDownloader.default.downloadImage(with: URL(string: mainImage)!, retrieveImageTask: nil, options: [], progressBlock: nil) { (image, _, _, data) in
//                let vc = HomeQuestPopViewController(questInfo: env.questInfo, mainImg: image)
//                vc.questPopMenuClose = { [weak self] in
//                    self?.isOpenedQuest = true
//                }
//                vc.modalPresentationStyle = .overFullScreen
//                vc.modalTransitionStyle = .crossDissolve
//                self.present(vc, animated: true, completion: nil)
//            }
//        }
    }

    /// 签到弹窗
    func showSignPopMenu() {
        guard let env = self.popupMenusEnvelope else { return }

        if env.signInfo.mainImage != nil {
            let vc = HomeSignPopViewController(signInfo: env.signInfo)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.showCouponHandle = { [weak self] coupons in
                let vc = HomeCouponSignPopViewController(coupons: coupons)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self?.present(vc, animated: true, completion: nil)
            }
            self.present(vc, animated: true, completion: nil)
            self.isOpenedSign = true
        }
    }

    /// 处理弹窗
    func handlePopMenu() {
        guard let env = self.popupMenusEnvelope else { return }

        // 初始化运营弹窗
        DanmakuService.shared.setup(adInfos: env.adInfo)

        // 取出上次展示时间
        let time = AppEnvironment.userDefault.object(forKey: PopMenuAdInfoUserDefaultKey + "-" + PopMenuAdInfo.ShowPage.Main.rawValue)

        if let timeDate = time { // 非第一次展示
            let isSameDay = Calendar.current.isDate(Date(), inSameDayAs: timeDate as! Date)
            if !env.adInfo.isEmpty && !isSameDay {
                showAdPopMenu(isFirstLanch: false)
            } else {
                continueToShow()
            }
        } else { // 第一次展示
            if !env.adInfo.isEmpty {
                showAdPopMenu(isFirstLanch: true)
            } else {
                continueToShow()
            }
        }
    }

    override func bindViewModels() {

        self.viewModel.popupMenusEnvelope
            .subscribe(onNext: { [weak self] env in
                guard let self = self else { return }
                self.popupMenusEnvelope = env
                self.handlePopMenu()
            })
            .disposed(by: disposeBag)

        self.viewModel.machineTagEnvelope
            .subscribe(onNext: { [weak self] env in
                self?.machineTagEnvelope = env
                
                // 设置背景图
                if let img = StaticAssetService.shared.envelope?.indexRoof {
                    self?.topBgIv.gas_setImageWithURL(img)
                }
                
                // 设置titleView数据
                var titles = ["推荐", "全部"]
                for machineTag in env.machineTagList {
                    titles.append(machineTag.title)
                }
                self?.titleView.titles = titles
                
                // 设置搜索条
                self?.searchBar.showNewUser(info: env.rightBarButtonInfo)
                if let placeholder = env.searchInfo.placeholder {
                    self?.searchBar.setPlaceholder(placeholder)
                }
                
                // 隐藏弹窗
                self?.loadingView.isHidden = true
                self?.homeReconnectView.isHidden = true

                // 初始化界面
                self?.setupChildVc()

                self?.updateVersion()
            })
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { [weak self] _ in
                self?.homeReconnectView.isHidden = false
                self?.loadingView.isHidden = true
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: HomeTitleViewDelegate {
    func titleView(_ titleView: HomeTitleView, didSelectItemAt indexPath: IndexPath) {
        self.showChildViewController(at: indexPath.row)
        self.scrollToPointVc(indexPath: indexPath)
    }
}

extension HomeViewController: UIPageViewControllerDataSource {

    /// 返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewControllers.count == 0 { return nil }
        guard let index = viewControllers.index(of: viewController) else {
            return nil
        }
        if index < viewControllers.count - 1 {
            return viewControllers[index+1]
        } else {
            return nil
        }
    }

    /// 返回当前页面的上一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewControllers.count == 0 { return nil }
        guard let index = viewControllers.index(of: viewController) else {
            return nil
        }
        if index > 0 {
            return viewControllers[index-1]
        } else {
            return nil
        }
    }
}

extension HomeViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let currentVC = pageViewController.viewControllers?.last,
            let index = viewControllers.index(of: currentVC)
            else { return }
        self.scrollToPointVc(indexPath: IndexPath(item: index, section: 0))
//        self.currentIndex = index
        self.titleView.currentIndex = index
    }
}

extension HomeViewController: SocketStatusReactable {

    func onReconnect() {
        socketReconnectView.show()
    }

    func onConnected() {
        socketReconnectView.hide()

        showBackCurrentGameButtonIfNeed()
    }
}
