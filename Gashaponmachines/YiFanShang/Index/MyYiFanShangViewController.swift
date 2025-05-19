import MJRefresh

class MyYiFanShangViewController: BaseViewController, Refreshable {

    var refreshHeader: MJRefreshHeader?

    let YiFanShangTableViewCellReusableIdentifier = "YiFanShangTableViewCellReusableIdentifier"

    let viewModel = MyYiFanShangViewModel()

    let emptyView = EmptyView(type: .myYfs)

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

    lazy var mysegmentView: MyYiFanShangSegmentView = {
        let view = MyYiFanShangSegmentView()
        view.selectedIdnexCallback = { [weak self] type in
            guard let self = self else { return }
            self.viewModel.pageIndex = 1
            self.viewModel.request.onNext(1)
            self.viewModel.selectedType.accept(type)
        }
        return view
    }()

    @objc func refreshHandle() {
        self.viewModel.refreshTrigger.onNext(())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshHandle), name: .yfsTabbarItemClick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshHandle), name: .yfsDetailPurchaseSeccess, object: nil)

        self.view.backgroundColor = .white
        
        let topBgIv = UIImageView(image: UIImage(named: "myyfs_list_top_bg"))
        view.addSubview(topBgIv)
        topBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(132)
        }
        
        let navBgIv = UIImageView(image: UIImage(named: "myyfs_list_nav_bg"))
        navBgIv.isUserInteractionEnabled = true
        view.addSubview(navBgIv)
        navBgIv.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let backIv = UIImageView(image: UIImage(named: "myyfs_list_back"))
        navBgIv.addSubview(backIv)
        backIv.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        let titleLb = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "我的元气赏")
        navBgIv.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(backIv.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        let backButton = UIButton()
        backButton.addTarget(self, action: #selector(popToVc), for: .touchUpInside)
        navBgIv.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.equalTo(titleLb)
        }
        
        view.addSubview(mysegmentView)
        mysegmentView.snp.makeConstraints { make in
            make.top.equalTo(navBgIv.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        view.addSubview(listTableView)
        listTableView.snp.makeConstraints { make in
            make.top.equalTo(mysegmentView.snp.bottom)
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func popToVc() {
        self.navigationController?.popViewController(animated: true)
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel.items
            .subscribe(onNext: { [weak self] items in
                self?.emptyView.isHidden = (items.count != 0)
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MyYiFanShangViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YiFanShangTableViewCellReusableIdentifier, for: indexPath) as! YiFanShangTableViewCell
        cell.configureWith(item: viewModel.items.value[indexPath.row],isEnd: false)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.items.value.count
    }
}

extension MyYiFanShangViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items.value[indexPath.row]
        if let link = item.link, link != "" {
            RouterService.route(to: link)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 182
    }
}
