import UIKit
import MJRefresh
import ESTabBarController_swift

private let AccquiredItemTableViewCellReusableIdentifier = "AccquiredItemTableViewCellReusableIdentifier"

class EggProductViewController: BaseViewController, Refreshable {

    var selectProduct: EggProduct?

    var isHaveData = false

    var isShowHeaderView = false

    var refreshHeadProduct: ((EggProduct) -> Void)?

    var viewModel = AccquiredItemViewModel()

    var refreshHeader: MJRefreshHeader?

    let emptyView = EggProductEmptyView()

    let bottomView = UIView.withBackgounrdColor(.white)
//    let bottomView = UIImageView(image: UIImage(named: "dancao_bottom_bg"))
    
    let headerViewH: CGFloat = 148

    lazy var headerView = AccquiredItemHeaderView()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: AccquiredItemCollectionViewCell.cellWH, height: AccquiredItemCollectionViewCell.cellWH)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12 + 68, right: 12)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .new_backgroundColor
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(AccquiredItemCollectionViewCell.self, forCellWithReuseIdentifier: AccquiredItemCollectionViewCellId)
        return cv
    }()

    let deliveryButton = UIButton.yellowBackgroundButton(title: "发货", boldFontSize: 28)

    let exchangeButton = UIButton.yellowBackgroundButton(title: "换取蛋壳", boldFontSize: 28)

    var type: EggProductType!
    
    /// 兑换蛋壳提示文字
    var eggExchangeTip: String = ""

    init(type: EggProductType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type

        self.viewModel.eggProductType.accept(type)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .refreshEggProduct, object: nil)

        setupUI()

        setupRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.selectProduct = nil
        self.collectionView.reloadData()
        self.hideHeaderView()
    }

    func setupUI() {
        // 头部详情
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(-headerViewH)
            make.left.right.equalToSuperview()
            make.height.equalTo(headerViewH)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        // 底部按钮部分
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
//            make.bottom.equalTo(-Constants.kTabBarHeight)
            make.height.equalTo(68)
        }

        deliveryButton.layer.cornerRadius = 8
        bottomView.addSubview(deliveryButton)
        deliveryButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
        }

        exchangeButton.layer.cornerRadius = 8
        bottomView.addSubview(exchangeButton)
        exchangeButton.snp.makeConstraints { make in
            make.centerY.size.equalTo(deliveryButton)
            make.left.equalTo(deliveryButton.snp.right).offset(12)
            make.right.equalTo(-12)
        }

        setupBottonTitle()
        
        collectionView.addSubview(emptyView)
        emptyView.isHidden = true
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }

    func setupBottonTitle() {
        switch type {
        case .general:
            deliveryButton.setTitle("发货", for: .normal)
            exchangeButton.setTitle("扭蛋换蛋壳", for: .normal)
        case .pieceEgg:
            deliveryButton.setTitle("合成", for: .normal)
            exchangeButton.setTitle("材料换蛋壳", for: .normal)
        case .oneprice:
            deliveryButton.setTitle("发货", for: .normal)
            exchangeButton.setTitle("元气赏换蛋壳", for: .normal)
        case .none:
            QLog.debug("")
        }
    }

    func setupRefresh() {
        refreshHeader = initRefreshHeader(.index, scrollView: collectionView) { [weak self] in
            self?.viewModel.refreshTrigger.onNext(())
            self?.hideHeaderView()
        }

        refreshHeader?.beginRefreshing()
    }

    @objc func refreshData() {
        refreshHeader?.beginRefreshing()
    }

    func showHeaderView() {
        if !self.isShowHeaderView {
            self.headerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(0)
            }
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            self.isShowHeaderView = true
        }
    }

    func hideHeaderView() {
        if self.isShowHeaderView {
            self.selectProduct = nil
            self.viewModel.selection.onNext(nil)

            self.headerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(-headerViewH)
            }
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }

            self.isShowHeaderView = false
        }
    }

    // 兑换
    @objc func startExchanging() {
        if self.type == .pieceEgg {
            let vc = PieceEggPopViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.comfirmButtonClickHandle = { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(ExchangeViewController(type: self.type), animated: true)
            }
            self.present(vc, animated: true, completion: nil)
        } else {
            let vc = RemindPopViewController(imageStr: "dancao_exchange_remind", title: "确认要换蛋壳吗", n1Text: self.eggExchangeTip)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.comfirmButtonClickHandle = { [weak self] in
                guard let s = self else { return }
                s.navigationController?.pushViewController(ExchangeViewController(type: s.type), animated: true)
            }
            self.present(vc, animated: true, completion: nil)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()
        
        collectionView.rx.reachedBottom
            .mapTo(())
            .skipWhile { self.viewModel.items.value.isEmpty }
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        // 错误
        self.viewModel.error
            .subscribe(onNext: { [weak self] env in
                self?.refreshHeader?.endRefreshing()
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.eggProductEnvelope.subscribe(onNext: { [weak self] env in
            MainViewController.refreshDate = Date()
            self?.eggExchangeTip = env.eggExchangeTip
        }).disposed(by: disposeBag)
        
        self.viewModel.items.subscribe(onNext: { [weak self] values in
            self?.emptyView.isHidden = values.count != 0
            self?.bottomView.isHidden = values.count == 0
            self?.refreshHeader?.endRefreshing()
            self?.collectionView.reloadData()
        }).disposed(by: disposeBag)

        // 去看看点击
        self.emptyView.lookButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.type.look()
            })
            .disposed(by: disposeBag)

        // 发货点击
        self.deliveryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.type == .pieceEgg {
                    self.navigationController?.pushViewController(CompositionViewController(), animated: true)
                } else {
                    self.navigationController?.pushViewController(DeliveryViewController(), animated: true)
                }
            })
            .disposed(by: disposeBag)

        // 兑换点击
        self.exchangeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.startExchanging()
            })
            .disposed(by: disposeBag)

        // 查看商品详情
        self.headerView.icon.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                if let product = self?.headerView.eggproduct {
                    let vc = AccquiredItemDetailViewController(product: product)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension EggProductViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccquiredItemCollectionViewCellId, for: indexPath) as! AccquiredItemCollectionViewCell
        cell.configureWith(product: viewModel.items.value[indexPath.row], type: self.type, selectProduct: self.selectProduct)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectProduct = viewModel.items.value[indexPath.row]
        self.selectProduct = selectProduct
        self.headerView.eggproduct = selectProduct
        self.showHeaderView()
        self.collectionView.reloadData()
    }
}

class EggProductEmptyView: UIView {

    let lookButton = UIButton()

    init() {
        super.init(frame: .zero)

        self.backgroundColor = .white

        let iv = UIImageView(image: UIImage(named: "dancao_empty"))
        self.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.kScreenHeight*0.17)
            make.centerX.equalToSuperview()
            make.width.equalTo(157)
            make.height.equalTo(173)
        }

        let titleLabel = UILabel.with(textColor: UIColor(hex: "bdbdbd")!, fontSize: 24, defaultText: "暂时还没有扭蛋哦~快去四处逛逛吧!")
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iv.snp.bottom).offset(12)
            make.height.equalTo(12)
        }

        lookButton.backgroundColor = .qu_yellow
        lookButton.setTitle("去看看", for: .normal)
        lookButton.setTitleColor(.qu_black, for: .normal)
        lookButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        lookButton.layer.cornerRadius = 8
        self.addSubview(lookButton)
        lookButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(38)
            make.width.equalTo(117)
            make.height.equalTo(33)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
