import MJRefresh
import AVFoundation

class YiFanShangViewController: BaseViewController, Refreshable {

    var refreshHeader: MJRefreshHeader?

    let YiFanShangTableViewCellReusableIdentifier = "YiFanShangTableViewCellReusableIdentifier"

    let viewModel = YiFanShangViewModel()

    /// 空白视图
    let emptyView = EmptyView(type: .yfs)

    // 元气赏TableView
    lazy var listTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.register(YiFanShangTableViewCell.self, forCellReuseIdentifier: YiFanShangTableViewCellReusableIdentifier)
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    // 元气赏选择标签View
    lazy var segmentView: YiFanShangSegmentView = {
        let view = YiFanShangSegmentView(frame: CGRect(x: 8, y: 0, width: Constants.kScreenWidth - 16, height: 60))
        view.selectedIdnexCallback = { type in
            self.viewModel.pageIndex = 1
            self.viewModel.request.onNext(1)
            self.viewModel.selectedType.accept(type)
        }
        return view
    }()

    /// 结束分割线插入位置
    var insertIndex: Int?

    @objc func refreshHandle() {
        self.viewModel.refreshTrigger.onNext(())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshHandle), name: .yfsTabbarItemClick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshHandle), name: .yfsDetailPurchaseSeccess, object: nil)

        self.view.backgroundColor = .white
        
        let topBgIv = UIImageView(image: UIImage(named: "yfs_list_top_bg"))
        if let img = StaticAssetService.shared.envelope?.onePieceRoof {
            topBgIv.gas_setImageWithURL(img)
        }
        view.addSubview(topBgIv)
        topBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        let rulerIv = UIImageView(image: UIImage(named: "yfs_list_ruler"))
        rulerIv.isUserInteractionEnabled = true
        rulerIv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushToRulerVc)))
        view.addSubview(rulerIv)
        rulerIv.snp.makeConstraints { make in
            make.top.equalTo(16 + Constants.kStatusBarHeight)
            make.left.equalTo(12)
            make.width.equalTo(96)
            make.height.equalTo(38)
        }
        
        let myYfsButton = UIButton.with(imageName: "yfs_list_my", target: self, selector: #selector(pushToMyYfsVc))
        view.addSubview(myYfsButton)
        myYfsButton.snp.makeConstraints { make in
            make.top.equalTo(16 + Constants.kStatusBarHeight)
            make.right.equalTo(-12)
            make.width.equalTo(88)
            make.height.equalTo(38)
        }
        
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(66 + Constants.kStatusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
        
        view.addSubview(listTableView)
        listTableView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        view.addSubview(emptyView)
        emptyView.isHidden = true
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(listTableView)
        }

        self.refreshHeader = initRefreshHeader(.index, scrollView: self.listTableView, {
            self.viewModel.refreshTrigger.onNext(())
        })

        self.refreshHeader?.beginRefreshing()

        self.showUserGuidePopVc()
    }
    
    @objc func pushToRulerVc() {
        self.navigationController?.pushViewController(YiFanShangRuleViewController(), animated: true)
    }
    
    @objc func pushToMyYfsVc() {
        self.navigationController?.pushViewController(MyYiFanShangViewController(), animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DanmakuService.shared.alertDelegate = self

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 展示运营弹窗
        DanmakuService.shared.showAlert(type: .OnePiece)
    }

    /// 显示用户引导弹窗
    func showUserGuidePopVc() {
        let showDate = UserDefaults.standard.object(forKey: NewUserGuideOnepieceKey)
        if showDate == nil && !AppEnvironment.isReal && AppEnvironment.stage == .release {
            let vc = NewUserGuidePopViewController(guideType: .onepiece)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel.items
            .subscribe(onNext: { [weak self] items in
                self?.emptyView.isHidden = (items.count != 0)
                self?.findEndIndex()
                self?.listTableView.reloadData()
                self?.refreshHeader?.endRefreshing()
            })
            .disposed(by: disposeBag)

        self.listTableView.rx.reachedBottom
            .mapTo(())
            .skipWhile { self.viewModel.items.value.isEmpty }
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)
    }

    /// 找到第一个已结束的位置
    func findEndIndex() {
        let items = self.viewModel.items.value
        insertIndex = items.firstIndex(where: { (item) -> Bool in
            let status = Int(item.status!.rawValue)!
            return status > 30
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension YiFanShangViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YiFanShangTableViewCellReusableIdentifier, for: indexPath) as! YiFanShangTableViewCell
        let item = self.viewModel.items.value[indexPath.row]

        if insertIndex != 0 && indexPath.row == insertIndex {
            cell.configureWith(item: item,isEnd: true)
        } else {
            cell.configureWith(item: item,isEnd: false)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.items.value.count
    }
}

extension YiFanShangViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.viewModel.items.value[indexPath.row]
        if let link = item.link, link != "" {
            RouterService.route(to: link)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == insertIndex, insertIndex != 0 { // 已结束
            return 254
        } else {
            return 182
        }
    }
}
