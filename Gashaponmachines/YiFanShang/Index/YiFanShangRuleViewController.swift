import MJRefresh

let YiFanShangRuleCellReusableIdentifier = "YiFanShangRuleCellReusableIdentifier"

class YiFanShangRuleViewController: BaseViewController{


    let viewModel = YiFanShangRuleViewModel()
    
    var rulesEnvelope: YiFanShangRuleListEnvelope? {
        didSet {
            if let rules = rulesEnvelope?.rules {
                self.rules = rules
                self.listTableView.reloadData()
            }
        }
    }
    
    var rules = [String]()

    lazy var listTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.bounces = false
        tv.register(YiFanShangRuleCell.self, forCellReuseIdentifier: YiFanShangRuleCellReusableIdentifier)
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        let titleLb = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "游戏规则")
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

        view.addSubview(listTableView)
        listTableView.snp.makeConstraints { make in
            make.top.equalTo(navBgIv.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        self.viewModel.requestRules.onNext(())
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

        self.viewModel.rulesEnvelope
            .subscribe(onNext: { [weak self] env in
                self?.rulesEnvelope = env
            })
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

extension YiFanShangRuleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YiFanShangRuleCellReusableIdentifier, for: indexPath) as! YiFanShangRuleCell
        cell.configureWith(imageURL: rules[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rules.count
    }
}

extension YiFanShangRuleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == rules.count - 1 {
            if let link = rulesEnvelope?.detailsLink.action {
                RouterService.route(to: link)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (Constants.kScreenWidth - 40) * 0.6
    }
}
