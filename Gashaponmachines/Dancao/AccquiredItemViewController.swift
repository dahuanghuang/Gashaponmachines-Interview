import UIKit
import RxSwift
import MJRefresh
import ESTabBarController_swift

class AccquiredItemViewController: BaseViewController {

    /// 蛋槽背景视图
    var pageBgView = UIView()

    /// 选中的类型
    var selectType: EggProductType = .general

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        setupChildVc()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DanmakuService.shared.alertDelegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DanmakuService.shared.showAlert(type: .EggProduct)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    /// 子控制器
    lazy var viewControllers: [EggProductViewController] = {
        var vcs = [EggProductViewController]()
        if AppEnvironment.isReal {
            return [EggProductViewController(type: .general)]
        } else {
            for type in EggProductType.allCases {
                vcs.append(EggProductViewController(type: type))
            }
        }

        return vcs
    }()

    /// 用于左右滑动切换控制器
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 0.0])

    /// 当前展示的视图
    var currentIndex: Int = 0

    /// 顶部选择视图
    let segmentView = EggProductSegmentView()

    override func bindViewModels() {
        super.bindViewModels()

        for vc in viewControllers {
            // 更新展架商品个数
            vc.viewModel.eggProductEnvelope
                .subscribe(onNext: { [weak self] env in
                    self?.segmentView.changeProductTitleCount(titles: [env.count.gameEggCount, env.count.pieceEggCount, env.count.onePieceEggCount])
                })
                .disposed(by: disposeBag)
        }
    }

    func setupUI() {
        
        let bgView = UIView.withBackgounrdColor(UIColor(hex: "FF902B")!)
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + 56)
        }
        
        let bgIv = UIImageView(image: UIImage(named: "dancao_top_bg"))
        bgView.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 状态栏
        let statusbar = UIView.withBackgounrdColor(.clear)
        bgView.addSubview(statusbar)
        statusbar.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.right.equalTo(view)
            make.height.equalTo(Constants.kStatusBarHeight)
        }

        segmentView.selectIndex = currentIndex
        segmentView.delegate = self
        bgView.addSubview(segmentView)
        segmentView.snp.makeConstraints { (make) in
            make.top.equalTo(statusbar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }

        view.addSubview(pageBgView)
        pageBgView.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }

        if AppEnvironment.isReal {
            segmentView.isHidden = true
        }
    }

    // 设置子控制器
    func setupChildVc() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        self.addChild(pageViewController)
        pageBgView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)

        showChildViewController(at: currentIndex)
    }

    /// 展示子控制器
    func showChildViewController(at index: Int) {
        if index >= viewControllers.count || index < 0 {
            return
        }

        // 上次显示的控制器index
        var lastIndex = 0
        if let currentVC = pageViewController.viewControllers?.last,
            let idx = viewControllers.index(of: currentVC as! EggProductViewController) {
            lastIndex = idx
        }

        let toVC = viewControllers[index]
        let direction: UIPageViewController.NavigationDirection = (index < lastIndex) ? .reverse : .forward
        pageViewController.setViewControllers([toVC], direction: direction, animated: true, completion: nil)
    }
}

extension AccquiredItemViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    /// 返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewControllers.count == 0 { return nil }
        guard let index = viewControllers.index(of: viewController as! EggProductViewController) else {
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
        guard let index = viewControllers.index(of: viewController as! EggProductViewController) else {
            return nil
        }
        if index > 0 {
            return viewControllers[index-1]
        } else {
            return nil
        }
    }

    // 完成滚动
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let currentVC = pageViewController.viewControllers?.last,
            let index = viewControllers.index(of: currentVC as! EggProductViewController)
            else { return }
        self.currentIndex = index
        self.segmentView.selectIndex = self.currentIndex
    }
}

extension AccquiredItemViewController: EggProductSegmentViewDelegate {
    func segmentView(_ segmentView: EggProductSegmentView, didSelectAt index: Int) {
        self.showChildViewController(at: index)
        self.currentIndex = index
        self.selectType = segmentView.selectType
    }
}
