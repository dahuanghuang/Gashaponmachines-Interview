import UIKit
import MJRefresh

extension Notification.Name {
    // 首页上划下划通知(搜索栏控制)
    public static let HomeContentPullUpScroll = Notification.Name("HomeContentPullUpScroll")
    public static let HomeContentPullDownScroll = Notification.Name("HomeContentPullDownScroll")
    // 运营弹窗关闭通知
    public static let AdPopupMenuClose = Notification.Name("AdPopupMenuClose")
    // 首页签到成功通知
    public static let HomeSignInSuccess = Notification.Name("HomeSignInSuccess")
}

class HomeRecommendViewController: BaseViewController, Refreshable {

    var recommendHeadEnvelope: HomeRecommendHeadEnvelope?

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    let recommendViewModel = HomeRecommendViewModel()

    /// 当前滚动的Y值
    var contentOffSetY: CGFloat = 0

    /// 上一次滚动是否向上
    var isScrollUp: Bool = false
    
    /// 头部视图
    var headerView: HomeRecommendHeadView?

    private lazy var waterFlowLayout: HomeRecommendWaterFlowLayout = {
        let layout = HomeRecommendWaterFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.waterFlowLayout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        cv.register(HomeRecommendWaterFlowCell.self, forCellWithReuseIdentifier: HomeRecommendWaterFlowCellId)
        cv.register(HomeRecommendHeadView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeRecommendHeadViewId)
        return cv
    }()

    /// 活动视图
    let activityIv = UIImageView()

    // MARK: - 系统方法
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshHeader = initRefreshHeader(.index, scrollView: self.collectionView, { [weak self] in
            self?.refreshFooter?.endRefreshing()
            self?.recommendViewModel.requestMainPage.onNext(())
            self?.recommendViewModel.refreshTrigger.onNext(())
        })

        self.refreshFooter = initBlackRefreshFooter(scrollView: self.collectionView, { [weak self] in
            self?.refreshHeader?.endRefreshing()
            self?.recommendViewModel.loadNextPageTrigger.onNext(())
        })

        view.backgroundColor = .clear

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        activityIv.isUserInteractionEnabled = true
        activityIv.isHidden = true
        activityIv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(routerAction)))
        view.addSubview(activityIv)
        activityIv.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.width.equalTo(74)
            make.height.equalTo(82)
            make.bottom.equalTo(-Constants.kTabBarHeight-36)
        }
        if let imgUrl = AppEnvironment.current.config?.floatImageInfo["image"] {
            activityIv.isHidden = false
            activityIv.gas_setImageWithURL(imgUrl)
        }

        recommendViewModel.requestMainPage.onNext(())
        recommendViewModel.refreshTrigger.onNext(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isScrollUp = false
    }

    // MARK: - Action
    @objc func routerAction() {
        if let actionUrl = AppEnvironment.current.config?.floatImageInfo["action"] {
            RouterService.route(to: actionUrl)
        }
    }

    // MARK: - Other
    override func bindViewModels() {
        recommendViewModel.items
            .subscribe(onNext: { [weak self] machines in
                self?.waterFlowLayout.datas = machines
                self?.collectionView.reloadData()
                self?.refreshHeader?.endRefreshing()
                self?.refreshFooter?.endRefreshing()
            })
            .disposed(by: disposeBag)

        recommendViewModel.recommendHeadEnvelope
            .subscribe(onNext: { [weak self] env in
                self?.recommendHeadEnvelope = env
                self?.waterFlowLayout.headViewH = HomeRecommendHeadView().getContentViewHeight(env: env)
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension HomeRecommendViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendViewModel.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecommendWaterFlowCellId, for: indexPath) as! HomeRecommendWaterFlowCell
        let machine = recommendViewModel.items.value[indexPath.row]
        cell.config(machine: machine, index: indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeRecommendHeadViewId, for: indexPath) as! HomeRecommendHeadView
        headerView.recommendHeadEnvelope = recommendHeadEnvelope
        self.headerView = headerView
        return headerView
    }
}

extension HomeRecommendViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let machine = recommendViewModel.items.value[indexPath.row]
        if let type = MachineColorType(rawValue: machine.type.rawValue) {
            // 登录界面
            guard AppEnvironment.current.apiService.accessToken != nil else {
                let vc = LoginViewController.controller
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
                return
            }
            // 游戏界面
            let vc = NavigationController(rootViewController: GameNewViewController(physicId: machine.physicId, type: type))
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            HUD.showError(second: 1.0, text: "机台类型出错", completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 控制header背景的显示和隐藏
        UIView.animate(withDuration: 0.5) {
            self.headerView?.bgIv.alpha = ((scrollView.contentOffset.y > -44) ? 0.0 : 1.0)
        }
        
        if scrollView.contentOffset.y < 0 {
            return
        }

        let difference = scrollView.contentOffset.y - contentOffSetY
        if difference > 0 { // 上拉
            if !isScrollUp {
                NotificationCenter.default.post(name: .HomeContentPullUpScroll, object: nil)
                isScrollUp = true
            }
        } else { // 下拉
            if isScrollUp {
                NotificationCenter.default.post(name: .HomeContentPullDownScroll, object: nil)
                isScrollUp = false
            }
        }

        contentOffSetY = scrollView.contentOffset.y
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        activityIv.snp.updateConstraints { make in
            make.right.equalTo(62)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        delayOn(0.5) {
            self.activityIv.snp.updateConstraints { make in
                make.right.equalTo(-12)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
