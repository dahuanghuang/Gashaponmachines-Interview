import ESTabBarController_swift
import SwiftNotificationCenter
import RxSwift
import RxCocoa
import Kingfisher

extension Notification.Name {
    /// 一番赏点击回调
    static let yfsTabbarItemClick = Notification.Name("yfsTabbarItemClick")

    /// 刷新蛋槽
    static let refreshEggProduct = Notification.Name("refreshEggProduct")
}

enum SystemTabBar: String, CaseIterable {
    case index = "index"
    case yifanshang = "yfs"
    case mall = "mall"
    case dancao = "dancao"
    case profile = "profile"

    var cropRect: CGRect {
        return CGRect(x: 0, y: 0, width: 49, height: 49)
    }

    var selectedImage: UIImage {
        return UIImage.cropImage(image: UIImage(named: "\(self.rawValue)_selected")!, cropRect: cropRect)
    }

    var unselectedImage: UIImage {
        return UIImage.cropImage(image: UIImage(named: "\(self.rawValue)_unselect")!, cropRect: cropRect)
    }

    static var selectedImageArray: [UIImage] {
        if self.viewControllers.count == 5 {
            return SystemTabBar.allCases.map { $0.selectedImage }
        } else {
            return SystemTabBar.allCases.filter { $0 != .yifanshang }.map { $0.selectedImage }
        }
    }

    static var unselectedImageArray: [UIImage] {
        if self.viewControllers.count == 5 {
            return SystemTabBar.allCases.map { $0.unselectedImage }
        } else {
            return SystemTabBar.allCases.filter { $0 != .yifanshang }.map { $0.unselectedImage }
        }
    }
    
    static var tabbars: [SystemTabBar] {
        if self.viewControllers.count == 5 {
            return SystemTabBar.allCases
        } else {
            return SystemTabBar.allCases.filter { $0 != .yifanshang }
        }
    }

    static var fourVCs: [UIViewController] {
        return [
            HomeViewController(),
            MallViewController(),
            AccquiredItemViewController(),
            ProfileViewController()]
        .map { NavigationController(rootViewController: $0) }
    }

    static var fiveVCs: [UIViewController] {
        return [
            HomeViewController(),
            YiFanShangViewController(),
            MallViewController(),
            AccquiredItemViewController(),
            ProfileViewController()
        ]
        .map { NavigationController(rootViewController: $0) }
    }

    static var viewControllers: [UIViewController] {
        return AppEnvironment.isYfs ? self.fiveVCs : self.fourVCs
    }
}

final class MainViewController: ESTabBarController {

    /// 是否需要去刷新蛋槽界面数据
    static var isEggProductRefresh: Bool = false

    /// 上次蛋槽刷新时间
    static var refreshDate = Date()

    /// 是否已经展示过审核时的说明弹框
    static let showReviewPopViewVCKey = "showReviewPopViewVCKey"

    let viewModel: MainViewModel = MainViewModel()

    private let disposeBag = DisposeBag()

    private var danmakuView: DanmakuView?
    
    /// 上一次点击index
    var lastTapIndex: Int?

    init() {
        super.init(nibName: nil, bundle: nil)

        if let tabBar = self.tabBar as? ESTabBar {
            tabBar.itemCustomPositioning = .fillIncludeSeparator
        }

        /// 点击响应(是否能劫持点击事件)
#warning("该地方不可写成[weak self], 因为MainViewController需要被该闭包循环引用, 然后添加到Broadcaster.observersDic属性中, 用弱引用MainViewController会被释放而导致该属性存放nil值, 引发crash --- 至于为什么这么设计, 我也很懵逼....")
        self.shouldHijackHandler = { (_ tb: UITabBarController, _ vc: UIViewController, _ index: Int) -> Bool in
//            guard let StrongSelf = self else { return false}
            
            // tabbar点击, 直接回到首页
            let nav = vc as? UINavigationController
            nav?.popToRootViewController(animated: true)

            if AppEnvironment.current.apiService.accessToken != nil || index == 0 {
                let isYfs = (self.tabBar.items?.count == 5 ? true : false)

                // 一番赏点击通知
                if isYfs && index == 1 {
                    NotificationCenter.default.post(name: .yfsTabbarItemClick, object: nil)
                }

                // 蛋槽刷新通知
                if isYfs && index == 3 {
                    self.updateEggProduct()
                }
                
                // 点击动画(需要展示时才进行展示)
                if let isAnimation = AppEnvironment.current.config?.isAnimation, isAnimation {
                    if let lastIndex = self.lastTapIndex, lastIndex != index {
                        // 停止上一次点击item的动画
                        if let item = tb.tabBar.items?[lastIndex] as? ESTabBarItem {
                            item.contentView?.imageView.animationImages?.removeAll()
                            item.contentView?.imageView.stopAnimating()
                        }

                        // 显示当前点击item的动画
                        if let item = tb.tabBar.items?[index] as? ESTabBarItem {
                            var images = [UIImage]()
                            for i in 0...14 {
                                let name = SystemTabBar.tabbars[index].rawValue
                                if let img = UIImage(named: "\(name)_select_\(i)") {
                                    images.append(img)
                                }
                            }
                            item.contentView?.imageView.animationImages = images
    //                        item.contentView?.imageView.animationDuration = 1
                            item.contentView?.imageView.animationRepeatCount = 1
                            item.contentView?.imageView.startAnimating()
                        }
                    }
                    // 记录点击item
                    self.lastTapIndex = index
                }
                
                return false
            } else {
                return true
            }
        }

        /// 劫持点击(shouldHijackHandler为true才能进来)
        self.didHijackHandler = { [unowned self] (_ tabBarController: UITabBarController, _ viewController: UIViewController, _ index: Int) -> Void in
            if AppEnvironment.current.apiService.accessToken == nil {
                self.notifyForLogin()
                return
            }
        }

        self.viewControllers = SystemTabBar.viewControllers

        self.setupDefaultTabbar()
    }

    /// 设置默认tabbar图片
    func setupDefaultTabbar() {
        guard let vcs = self.viewControllers else {
            return
        }

        for (index, vc) in vcs.enumerated() {
             vc.configureItem(index: index, selectedImageArray: selectedImageArray, unselectImageArray: unselectImageArray)
        }

        self.selectedIndex = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        Broadcaster.register(Routable.self, observer: self)
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = .white.alpha(0.9)

        bindViewModels()

        self.viewModel.viewDidLoad.onNext(())
    }

    private func bindViewModels() {

        self.viewModel.assetsEnvelope
            .subscribe(onNext: { [weak self] env in
                self?.setupTabBarItemFrom(assets: env.newBottomTab ?? [])

                StaticAssetService.shared.envelope = env
                StaticAssetService.shared.startDownloadTasks(by: env)

                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.viewModel.staticAssets = env

                self?.selectedIndex = 0
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if AppEnvironment.isReal, !AppEnvironment.userDefault.bool(forKey: MainViewController.showReviewPopViewVCKey) {
            AppEnvironment.userDefault.set(true, forKey: MainViewController.showReviewPopViewVCKey)
            let vc = ReviewPopViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    deinit {
//        QLog.debug(NSStringFromClass(type(of: self)) + " DEINIT😍")
//    }

    var selectedImageArray = SystemTabBar.selectedImageArray
    var unselectImageArray = SystemTabBar.unselectedImageArray

    func setupTabBarItemFrom(assets: [StaticAssetsEnvelope.TabAssets]) {
        var mutable = assets

        // 移除一番赏
        if assets.count == 5, SystemTabBar.viewControllers.count == 4 {
            mutable.remove(at: 1)
        }

        guard let vcs = self.viewControllers else { return }

        let array = mutable.flatMap { [($0.image_selected, $0.image_unselect)] }

        for (index, pair) in array.enumerated() {
            let vc = vcs[index]

            guard let select = pair.0, let unselect = pair.1 else { break }
            
//            ImageCache.default.retrieveImageInDiskCache(forKey: select) { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case .success(let selectImg):
//                    if let img = selectImg {
//                        self.selectedImageArray[index] = img
//                    }
//                    vc.configureItem(index: index, selectedImageArray: self.selectedImageArray, unselectImageArray: self.unselectImageArray)
//                case .failure(let _):
//                    ImageDownloadManager.shared.downloadImages(imageStrs: [select]) { [weak self] images in
//                        guard let image = images.first else { return }
//                        ImageCache.default.store(image, forKey: select, options: )
//                    }
//                }
//            }
            
            

            /*
            if let selectImg = ImageCache.default.retrieveImageInDiskCache(forKey: select) {
                selectedImageArray[index] = selectImg
                vc.configureItem(index: index, selectedImageArray: selectedImageArray, unselectImageArray: unselectImageArray)
            } else {
                ImageDownloader.default.downloadImage(with: URL(string: select)!, retrieveImageTask: nil, options: [], progressBlock: nil) { [weak self] (image, _, _, data) in
                    guard let self = self, let image = image else { return }
                    ImageCache.default.store(image, forKey: select)
                    self.selectedImageArray[index] = image
                    vc.configureItem(index: index, selectedImageArray: self.selectedImageArray, unselectImageArray: self.unselectImageArray)
                }
            }

            if let unselectImg = ImageCache.default.retrieveImageInDiskCache(forKey: unselect) {
                unselectImageArray[index] = unselectImg
                vc.configureItem(index: index, selectedImageArray: selectedImageArray, unselectImageArray: unselectImageArray)
            } else {
                ImageDownloader.default.downloadImage(with: URL(string: unselect)!, retrieveImageTask: nil, options: [], progressBlock: nil) { [weak self] (image, _, _, _) in
                    guard let self = self, let image = image else { return }
                    ImageCache.default.store(image, forKey: unselect)
                    self.unselectImageArray[index] = image
                    vc.configureItem(index: index, selectedImageArray: self.selectedImageArray, unselectImageArray: self.unselectImageArray)
                }
            }
             */
        }
    }

    /// 蛋槽刷新策略:
    /// 点击蛋槽tab时, 若为可刷新状态, 就会去刷新蛋槽界面的数据
    /// 若为不可刷新状态, 则去判断这次点击时间和上次点击时间间隔
    /// 若大于5分钟, 则刷新, 反之不会刷新
    /// 当扭完蛋或购买元气赏后, 就设置成可刷新状态
    /// 每次刷新完数据, 会重置刷新状态和刷新时间
    func updateEggProduct() {
        if MainViewController.isEggProductRefresh { // 可刷新

            NotificationCenter.default.post(name: .refreshEggProduct, object: nil)

            MainViewController.isEggProductRefresh = false

        } else { // 不可刷新

            let minuteDiff = (Date().minute - MainViewController.refreshDate.minute)

            if minuteDiff >= 2 {

                NotificationCenter.default.post(name: .refreshEggProduct, object: nil)

                MainViewController.isEggProductRefresh = false
            }
        }
    }
}

extension UIViewController {
    func configureItem(index: Int, selectedImageArray: [UIImage?], unselectImageArray: [UIImage?]) {
        let item = ESTabBarItem(CustomTabBarItemContentView(), title: nil, image: unselectImageArray[index], selectedImage: selectedImageArray[index])
        if DeviceType.IS_IPHONE_X_SERIERS {
            item.contentView?.badgeOffset = UIOffset(horizontal: 0, vertical: -40)
        }
        
        self.tabBarItem = item
    }
}

struct MainViewModel {

    var viewDidLoad = PublishSubject<Void>()

    var assetsEnvelope: Observable<StaticAssetsEnvelope>

    init() {

        let response = self.viewDidLoad.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getStaticAssets().materialize()
        	}
            .share(replay: 1)
        	.elements()

        self.assetsEnvelope = response
    }
}
