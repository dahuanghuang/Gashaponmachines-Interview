import SnapKit
import UIKit

extension Notification.Name {
    /// 刷新一番赏详情界面
    static let refreshYiFanShangDetail = Notification.Name("refreshYiFanShangDetail")
}

class YiFanShangDetailViewController: BaseViewController {

    let YiFanShangDetailRecordTableViewCellReuseIdentifier = "YiFanShangDetailRecordTableViewCellReuseIdentifier"

    /// 详情viewModel
    var detailViewModel: YiFanShangDetailViewModel!

    /// 红色导航条
    var navigationBar = UIView()
    
    /// 导航条显示进度
    let progressLabel = UILabel.numberFont(size: 16)

    // 顶部标题(第几弹)
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.with(textColor: .white, boldFontSize: 32)
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    /// 直播按钮
    lazy var livesteamButton: UIButton = UIButton.with(imageName: "yfs_livestream")

    lazy var detailHeaderView: YiFanShangDetailHeaderView = {
        let view = YiFanShangDetailHeaderView()
        view.awardClickHandle = { [weak self] index in
            guard let awardInfos = self?.detailEnvelope?.awardInfo else { return }
            let vc = YiFanShangDetailRewardInfoViewController(awardInfos: awardInfos, selectIndex: index)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self?.present(vc, animated: true, completion: nil)
        }
        return view
    }()
    
    lazy var footerView: UILabel = {
        let lb = UILabel.with(textColor: .white.alpha(0.6), fontSize: 24, defaultText: "没有更多数据了～")
        lb.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 30)
        lb.textAlignment = .center
        return lb
    }()

    lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor(hex: "FF7C74")
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.tableHeaderView = detailHeaderView
        tableView.tableFooterView = footerView
        tableView.register(YiFanShangDetailRecordTableViewCell.self, forCellReuseIdentifier: YiFanShangDetailRecordTableViewCellReuseIdentifier)
        return tableView
    }()

    /// 底部购买视图
    let bottomPurchaseView = YiFanShangDetailBottomPurchaseView()

    /// 占位图
    let placehoderIv = UIImageView(image: UIImage(named: "yfs_detail_placehoder"))

    var detailEnvelope: YiFanShangDetailEnvelope?

    // MARK: - 初始化方法
    init(recordId: String) {
        super.init(nibName: nil, bundle: nil)
        self.detailViewModel = YiFanShangDetailViewModel(onePieceTaskRecordId: recordId)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(requestData), name: .refreshYiFanShangDetail, object: nil)

        setupConfiguration()

        setupPurchaseView()

        setupTableView()

        setupNav()

        setupButtons()

        showUserGuidePopVc()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        // 请求数据
        self.requestData()
    }

    /// 初始化配置
    func setupConfiguration() {
        view.backgroundColor = UIColor(hex: "FF7C74")
        if #available(iOS 11.0, *) {
            contentTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    /// 初始化状态条
    func setupNav() {
        // 导航栏
        navigationBar.backgroundColor = UIColor(hex: "FF4B6B")
        navigationBar.alpha = 0.0
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        // 顶部右边进度值视图
        let progressContainer = RoundedCornerView(corners: .allCorners, radius: 10, backgroundColor: .white)
        navigationBar.addSubview(progressContainer)
        progressContainer.snp.makeConstraints { make in
            make.bottom.equalTo(-12)
            make.right.equalTo(-12)
            make.width.equalTo(55)
            make.height.equalTo(20)
        }
        
        let progressIv = UIImageView(image: UIImage(named: "yfs_detail_top_progress"))
        progressContainer.addSubview(progressIv)
        progressIv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(51)
            make.height.equalTo(16)
        }
        
        progressLabel.textColor = .black
        progressContainer.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 标题
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        // 返回按钮
        let quitButton = UIButton.with(imageName: "profile_back")
        quitButton.addTarget(self, action: #selector(quit), for: .touchUpInside)
        view.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalTo(titleLabel)
        }
    }

    /// 初始化底部购买视图
    func setupPurchaseView() {
        // 购买视图
        bottomPurchaseView.isHidden = true
        view.addSubview(bottomPurchaseView)
        bottomPurchaseView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(104+Constants.kScreenBottomInset)
        }
    }

    func setupTableView() {
        // tableView
        view.insertSubview(contentTableView, belowSubview: bottomPurchaseView)
        contentTableView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomPurchaseView.snp.top)
        }
    }

    /// 初始化按钮
    func setupButtons() {

        // 直播
        view.addSubview(livesteamButton)
        livesteamButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 66, height: 52))
            make.top.equalToSuperview().offset(Constants.kStatusBarHeight + 79)
            make.right.equalToSuperview()
        }

        // 无数据占位图
        view.addSubview(placehoderIv)
        placehoderIv.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
    }

    // MARK: - 自定义方法
    /// 显示用户引导弹窗
    func showUserGuidePopVc() {
        let showDate = UserDefaults.standard.object(forKey: NewUserGuideOnepieceDetailKey)
        if showDate == nil && !AppEnvironment.isReal && AppEnvironment.stage == .release {
            let vc = NewUserGuidePopViewController(guideType: .onepieceDetail)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }

    /// // 设置底部购买视图展示
    func changePurchaseViewDisplay(env: YiFanShangDetailEnvelope) {
        if let type = env.actionButtonType {
            switch type {
            case .canPurchase, .detail: // 显示
                if let currentCount = env.currentCount, let totalCount = env.totalCount,
                    let cCount = Int(currentCount), let tCount = Int(totalCount) {
                    if cCount == tCount { // 卖光
                        hidePurchaseView()
                    } else { // 在售
                        showPurchaseView()
                    }
                }
            case .canNotPurchased: // 隐藏
                hidePurchaseView()
            }
        }
    }

    /// 展示底部购买视图
    func showPurchaseView() {
        bottomPurchaseView.isHidden = false
        contentTableView.snp.remakeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomPurchaseView.snp.top)
        }
    }

    /// 隐藏底部购买视图
    func hidePurchaseView() {
        bottomPurchaseView.isHidden = true
        contentTableView.snp.remakeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.kScreenBottomInset)
        }

        detailHeaderView.magicView.changeMagicState(isOpen: false)
    }

    /// 退出
    @objc func quit() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    /// 重新布局headerView的高度
    func layoutHeadView(env: YiFanShangDetailEnvelope) {
        if env.awardInfo == nil { return }
        let headerViewH = detailHeaderView.getHeaderHeight(env: env)
        detailHeaderView.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: headerViewH)
    }

    /// 请求数据
    @objc func requestData() {
        detailViewModel.viewDidLoadTrigger.onNext(())
    }

    // MARK: - 数据绑定
    override func bindViewModels() {
        super.bindViewModels()
        
        self.detailViewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)

        self.detailViewModel.detailEnvelope
            .bind(to: detailHeaderView.rx.envelope)
            .disposed(by: disposeBag)

        self.detailViewModel.detailEnvelope
            .subscribe(onNext: { [weak self] env in
                if let serial = env.serial {
                    self?.titleLabel.text = "第 \(serial) 弹"
                }
                if let cCount = env.currentCount, let tCount = env.totalCount {
                    self?.progressLabel.text = "\(cCount)/\(tCount)"
                }
                self?.placehoderIv.isHidden = true

                self?.detailEnvelope = env

                self?.layoutHeadView(env: env)

                self?.bottomPurchaseView.configWith(env: env)

                // 改变位置
                self?.changePurchaseViewDisplay(env: env)
            })
            .disposed(by: disposeBag)

        // 设置tableView数据
        self.contentTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        self.detailViewModel.detailEnvelope
            .map { $0.ticketList }
            .filterNil()
            .asDriver(onErrorJustReturn: [])
            .drive(self.contentTableView.rx.items(cellIdentifier: YiFanShangDetailRecordTableViewCellReuseIdentifier, cellType: YiFanShangDetailRecordTableViewCell.self)) { [weak self] (ip, item, cell) in
                let count = self?.detailEnvelope?.ticketList?.count ?? 0
                cell.configureWith(ticket: item, isLast: ip == count-1)
                cell.isEvenNumber = ip % 2 == 0
            }
            .disposed(by: disposeBag)

        // 立即购买
        bottomPurchaseView.purchaseButton.rx.tap.asObservable()
            .withLatestFrom(self.detailViewModel.detailEnvelope)
            .subscribe(onNext: { [weak self] env in
                guard let self = self else { return }
                let purchaseVc = YiFanShangPurchaseViewController(env: env)
                purchaseVc.refreshDataCallBack = { [weak self] in
                    self?.requestData()
                }
                let vc = NavigationController(rootViewController: purchaseVc)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        // 充值
        bottomPurchaseView.rechargeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.pushViewController(RechargeViewController(isOpenFromGameView: true), animated: true)
            })
            .disposed(by: disposeBag)

        // 跳转直播界面
        livesteamButton.rx.tap.asObservable()
            .withLatestFrom(self.detailViewModel.detailEnvelope)
            .subscribe(onNext: { [weak self] env in
                if let id = env.onePieceTaskRecordId {
                    let vc = YFSLivestreamViewController(roomId: id)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)

        /// 票券查看详情点击
        detailHeaderView.ticketView.lookButton.rx.tap.asObservable()
            .withLatestFrom(self.detailViewModel.detailEnvelope)
            .subscribe(onNext: { [weak self] env in
                if let type = env.actionButtonType {
                    switch type {
                    case .canPurchase, .canNotPurchased:
                        HUD.showError(second: 1.0, text: "还没购买", completion: nil)
                    case .detail:
                        if let id = env.onePieceTaskRecordId {
                            let purchaseRecordListVc = YiFanShangPurchaseRecordListViewController(onePieceTaskRecordId: id)
                            self?.navigationController?.pushViewController(purchaseRecordListVc, animated: true)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        /// 魔法阵购买点击
        detailHeaderView.magicView.magicEnterButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let env = self?.detailEnvelope else { return }
                let vc = YiFanShangMagicViewController(env: env)
                vc.refreshDataCallBack = { [weak self] in
                    self?.requestData()
                }
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        /// 魔法阵规则点击
        detailHeaderView.magicView.ruleButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                RouterService.route(to: self?.detailEnvelope?.magicDetail?.ruleURL)
            })
            .disposed(by: disposeBag)
    }
}

extension YiFanShangDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var y = scrollView.contentOffset.y
        if y <= 0 { // 下拉
            navigationBar.alpha = 0.0
        } else { // 上拉
            if y >= navigationBar.height {
                y = navigationBar.height
            }
            navigationBar.alpha = y/navigationBar.height
        }
    }
}
