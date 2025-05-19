import UIKit
import Tabman
import Pageboy

class DeliveryRecordViewController: BaseViewController {
    
    init(status: DeliveryStatus = .toBeDelivered) {
        super.init(nibName: nil, bundle: nil)
        self.status = status
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var status: DeliveryStatus = .toBeDelivered
    
    /// 子控制器
    let viewControllers = DeliveryStatus.allCases
        .filter { $0 != .canceled }
        .map { DeliveryRecordListViewController(status: $0) }
    
    ///
    lazy var titleView: CustomTitleView = {
        let view = CustomTitleView(style: .divide)
        view.titles = DeliveryStatus.allCases.filter{ $0 != .canceled }.map{ $0.description }
        view.delegate = self
        return view
    }()
    
    /// 滚动视图
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.bounces = false
        return scrollView
    }()
    
    /// 用于左右滑动切换控制器
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 10.0])
    
    /// 顶部渐变背景图
    let topBgIv = UIImageView(image: UIImage(named: "delivery_record_top"))
    
    /// 导航栏
    let navBar = CustomNavigationBar()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor
        
        view.addSubview(topBgIv)
        topBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight + 44)
        }
    
        navBar.backgroundColor = .clear
        navBar.title = "发货记录"
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        titleView.backgroundColor = .clear
        view.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        setupPageVc()
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentScrollNotification(notification:)), name: .DeliveryRecordContentPullScroll, object: nil)
    }
    
    func setupPageVc() {

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        self.addChild(pageViewController)
        scrollView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        
        let index =  DeliveryStatus.allCases.filter { $0 != .canceled }.firstIndex(of: self.status) ?? 0
        self.showChildViewController(at: index)
        self.titleView.scrollToItem(indexPath: IndexPath(item: index, section: 0))
        self.titleView.currentIndex = index
    }
    
    /// 展示子控制器
    func showChildViewController(at index: Int) {
        if index >= viewControllers.count || index < 0 {
            return
        }
        // 找出当前视图
        var currentIndex = 0
        if let vc = pageViewController.viewControllers?.last,
           let currentVC = vc as? DeliveryRecordListViewController,
           let idx = viewControllers.index(of: currentVC) {
            currentIndex = idx
        }
        // 移动到目标视图
        let toVC = viewControllers[index]
        let direction: UIPageViewController.NavigationDirection = (currentIndex > index) ? .reverse : .forward
        pageViewController.setViewControllers([toVC], direction: direction, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func contentScrollNotification(notification: Notification) {
        if let isPullTop = notification.userInfo?["isPullTop"] as? Bool { // 是否拉到顶部
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                self.navBar.backgroundColor = isPullTop ? .clear : .white
                self.titleView.backgroundColor = isPullTop ? .clear : .white
            }, completion: nil)
        }
    }
}

extension DeliveryRecordViewController: UIPageViewControllerDataSource {

    /// 返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewControllers.count == 0 { return nil }
        guard
            let proxyVC = viewController as? DeliveryRecordListViewController,
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
            let proxyVC = viewController as? DeliveryRecordListViewController,
            let index = viewControllers.index(of: proxyVC)
            else { return nil }
        if index > 0 {
            return viewControllers[index-1]
        }
        return nil
    }
}

extension DeliveryRecordViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let vc = pageViewController.viewControllers?.last,
            let currentVC = vc as? DeliveryRecordListViewController,
            let index = viewControllers.index(of: currentVC)
            else { return }
        // 滚动到该位置
        self.titleView.scrollToItem(indexPath: IndexPath(item: index, section: 0))
        self.titleView.currentIndex = index
    }
}


extension DeliveryRecordViewController: CustomTitleViewDelegate {
    func titleView(_ titleView: CustomTitleView, didSelectItemAt indexPath: IndexPath) {
        self.showChildViewController(at: indexPath.row)
        self.titleView.scrollToItem(indexPath: indexPath)
    }
}
