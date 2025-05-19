import UIKit
import Tabman
import Pageboy

class CouponRecordViewController: BaseViewController {

    let viewControllers = CouponType.allCases
    .filter { $0 != .AVAIL }
    .map { CouponViewController(couponType: $0, isNeedNav: false) }
    
    lazy var titleView: CustomTitleView = {
        let view = CustomTitleView(style: .divide)
        view.titles = CouponType.allCases.filter{ $0 != .AVAIL }.map{ $0.description }
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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .new_backgroundColor
        
        let navBar = CustomNavigationBar()
        navBar.backgroundColor = .clear
        navBar.title = "历史记录"
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
        
        self.showChildViewController(at: 0)
        self.titleView.scrollToItem(indexPath: IndexPath(item: 0, section: 0))
        self.titleView.currentIndex = 0
    }

    /// 展示子控制器
    func showChildViewController(at index: Int) {
        if index >= viewControllers.count || index < 0 {
            return
        }
        // 找出当前视图
        var currentIndex = 0
        if let vc = pageViewController.viewControllers?.last,
           let currentVC = vc as? CouponViewController,
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
}

extension CouponRecordViewController: UIPageViewControllerDataSource {

    /// 返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewControllers.count == 0 { return nil }
        guard
            let proxyVC = viewController as? CouponViewController,
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
            let proxyVC = viewController as? CouponViewController,
            let index = viewControllers.index(of: proxyVC)
            else { return nil }
        if index > 0 {
            return viewControllers[index-1]
        }
        return nil
    }
}

extension CouponRecordViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let vc = pageViewController.viewControllers?.last,
            let currentVC = vc as? CouponViewController,
            let index = viewControllers.index(of: currentVC)
            else { return }
        // 滚动到该位置
        self.titleView.scrollToItem(indexPath: IndexPath(item: index, section: 0))
        self.titleView.currentIndex = index
    }
}


extension CouponRecordViewController: CustomTitleViewDelegate {
    func titleView(_ titleView: CustomTitleView, didSelectItemAt indexPath: IndexPath) {
        self.showChildViewController(at: indexPath.row)
        self.titleView.scrollToItem(indexPath: indexPath)
    }
}
