import UIKit
import RxSwift
import RxCocoa
import SnapKit

let MallCollectionViewCellWidth = (Constants.kScreenWidth - 16-2) / 3
let MallSegmentCollectionViewCellReusIdentifier = "MallSegmentCollectionViewCellReusIdentifier"

class MallViewController: BaseViewController {
    
    lazy var headerView: MallHeaderView = {
        let view = MallHeaderView()
        view.delegate = self
        return view
    }()
    
    lazy var titleView: CustomTitleView = {
        let view = CustomTitleView(style: .normal)
        view.delegate = self
        return view
    }()

    var viewModel = MallViewModel()

    /// 子控制器
    var viewControllers: [UIViewController] = []

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

    /// 当前展示的视图
    var currentIndex: Int = 0
    
    /// 顶部渐变颜色背景图
    let topBgIv = UIImageView(image: UIImage(named: "mall_top_bg"))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        if let img = StaticAssetService.shared.envelope?.mallRoof {
            topBgIv.gas_setImageWithURL(img)
        }
        view.addSubview(topBgIv)
        topBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + 108)
        }

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        view.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(44)
            make.left.right.equalTo(headerView)
        }

        self.showUserGuidePopVc()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DanmakuService.shared.alertDelegate = self

        self.viewModel.viewWillAppearTrigger.onNext(())

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 展示运营弹窗
        DanmakuService.shared.showAlert(type: .Mall)
    }
    
    func setupPageVc(collections: [MallCollection]) {

        if viewControllers.count > 0 || collections.isEmpty {
            return
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        for i in 0...collections.count-1 {
            if let id = collections[i].mallCollectionId {
                viewControllers.append(MallChildViewController(mallCollectionId: id))
            }
        }
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        scrollView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        showChildViewController(at: 0)
    }

    /// 展示子控制器
    func showChildViewController(at index: Int) {
        if index >= viewControllers.count || index < 0 {
            return
        }
        // 找出当前视图
        var currentIndex = 0
        if let currentVC = pageViewController.viewControllers?.last, let idx = viewControllers.index(of: currentVC) {
            currentIndex = idx
        }
        // 移动到目标视图
        let toVC = viewControllers[index]
        let direction: UIPageViewController.NavigationDirection = (currentIndex > index) ? .reverse : .forward
        pageViewController.setViewControllers([toVC], direction: direction, animated: true, completion: nil)
    }

    /// 显示用户引导弹窗
    func showUserGuidePopVc() {
        let showDate = UserDefaults.standard.object(forKey: NewUserGuideMallKey)
        if showDate == nil && !AppEnvironment.isReal && AppEnvironment.stage == .release {
            let vc = NewUserGuidePopViewController(guideType: .mall)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()
        
        // 子控制器展示
        self.viewModel.mallInfo.asObservable()
            .subscribe(onNext: { [weak self] info in
                
                // 设置headerView数据
                self?.headerView.balance = info.balance
                
                // 设置titleView数据
                self?.titleView.titles = info.collections.map { $0.title }
                
                // 初始化界面
                self?.setupPageVc(collections: info.collections)
            })
            .disposed(by: disposeBag)
    }
}

extension MallViewController: UIPageViewControllerDataSource {

    /// 返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewControllers.count == 0 { return nil }
        guard
            let proxyVC = viewController as? MallChildViewController,
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
            let proxyVC = viewController as? MallChildViewController,
            let index = viewControllers.index(of: proxyVC)
            else { return nil }
        if index > 0 {
            return viewControllers[index-1]
        }
        return nil
    }
}

extension MallViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let currentVC = pageViewController.viewControllers?.last,
            let index = viewControllers.index(of: currentVC)
            else { return }
        // 滚动到该位置
        self.titleView.scrollToItem(indexPath: IndexPath(item: index, section: 0))
        self.titleView.currentIndex = index
        
    }
}

extension MallViewController: CustomTitleViewDelegate {
    func titleView(_ titleView: CustomTitleView, didSelectItemAt indexPath: IndexPath) {
        self.showChildViewController(at: indexPath.row)
        self.titleView.scrollToItem(indexPath: indexPath)
    }
}

extension MallViewController: MallHeaderViewDelegate {
    func didClickRecordButton() {
        self.navigationController?.pushViewController(MallRecordViewController(), animated: true)
    }
    
    func didClickSaerchButton() {
        // 登录界面
        guard AppEnvironment.current.apiService.accessToken != nil else {
            let vc = LoginViewController.controller
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            return
        }

        // 搜索
        let searchVc = SearchViewController(placeholder: "高达", keywords: ["高达", "美妆", "蕾姆", "假面骑士"])
        navigationController?.pushViewController(searchVc, animated: false)
    }
}
