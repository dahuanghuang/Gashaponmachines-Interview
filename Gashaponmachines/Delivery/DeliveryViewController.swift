import RxDataSources
import RxCocoa
import RxSwift
import MJRefresh

private let HeaderViewHeight: CGFloat = 48
private let DeliveryTableViewCellReusableIdentifier = "DeliveryTableViewCellReusableIdentifier"

class DeliveryViewController: BaseViewController, Refreshable {

    let viewModel = DeliveryViewModel()

    let bottomToolbar = DeliveryBottomToolbar(style: .start)

    let bottomTipView: DeliveryBottomTipView = DeliveryBottomTipView()

    var types: [EggProductListEnvelope.ProductType] = []

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    var currentSnackSelectionCell: DeliveryTableViewCell?

    // 缓存 item 应该显示的图片
    // [item.orderId: collection]
    var collectionIdsDic: [String: EggProduct.Collection] = [:]

    let dropDownView = GameRecordDropDownView()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.emptyDataSetDelegate = self
        tv.emptyDataSetDataSource = self
        tv.backgroundColor = .new_backgroundColor
        tv.register(DeliveryTableViewCell.self, forCellReuseIdentifier: DeliveryTableViewCellReusableIdentifier)
        return tv
    }()
    
    let navBar = CustomNavigationBar()
    
    let arrowIv = UIImageView(image: UIImage(named: "game_record_arrow_up"))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .new_backgroundColor
        
        navBar.backgroundColor = .new_backgroundColor
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        let titleView = UIView.withBackgounrdColor(.clear)
        navBar.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.left.equalTo(52)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
        }
        
        let titleLabel = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "全部物品发货")
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        titleView.addSubview(arrowIv)
        arrowIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right)
            make.size.equalTo(28)
        }
        
        let titleButton = UIButton()
        titleButton.addTarget(self, action: #selector(titleButtonClick), for: .touchUpInside)
        titleView.addSubview(titleButton)
        titleButton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(arrowIv)
            make.centerY.height.equalToSuperview()
        }

        view.addSubview(bottomToolbar)
        bottomToolbar.snp.makeConstraints { make in
            make.height.equalTo(60+Constants.kScreenBottomInset)
            make.left.right.equalTo(self.view)
            make.bottom.equalToSuperview()
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.equalTo(bottomToolbar.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }

        tableView.addSubview(bottomTipView)
        bottomTipView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(bottomToolbar.snp.top)
        }

        dropDownView.delegate = self
        dropDownView.isHidden = true
        dropDownView.frame = CGRect(x: 0, y: Constants.kStatusBarHeight + Constants.kNavHeight, width: Constants.kScreenWidth, height: 0)
        view.addSubview(dropDownView)

        refreshHeader = initRefreshHeader(.index, scrollView: tableView) { [weak self] in
            self?.viewModel.refreshTrigger.onNext(())
        }

        refreshHeader?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .bind(to: self.tableView.rx.items(cellIdentifier: DeliveryTableViewCellReusableIdentifier, cellType: DeliveryTableViewCell.self)) { [weak self] (_, item, cell) in
                guard let Strongself = self else { return }
            	cell.bind(to: Strongself.viewModel.state.asDriver(onErrorJustReturn: Set()), as: item)
                cell.configureWith(product: item)
                if let collection = self?.collectionIdsDic[item.orderId!] {
                    cell.iv.gas_setImageWithURL(collection.image)
                }
        	}
        	.disposed(by: disposeBag)

        Driver.zip(
            self.tableView.rx.modelSelected(EggProduct.self).asDriver(),
            self.tableView.rx.itemSelected.asDriver()
        	)
        	.drive(onNext: { pair in
            	self.viewModel.selectedSubject.onNext(pair)
                // 如果选中新的集合商品，更新
                if pair.0.collections != nil {
                    self.currentSnackSelectionCell = self.tableView.cellForRow(at: pair.1) as? DeliveryTableViewCell
                }
        	})
        	.disposed(by: disposeBag)

        self.viewModel.types
            .subscribe(onNext: { [weak self] types in
                self?.types = types
                self?.dropDownView.setupButtons(titles: types.compactMap { $0.name })
            })
            .disposed(by: disposeBag)

        self.viewModel.isSelectedAll
            .bind(to: self.bottomToolbar.rx.isSelectedAll)
            .disposed(by: disposeBag)

        self.tableView.rx.reachedBottom
            .mapTo(())
            .skipWhile { self.viewModel.items.value.isEmpty }
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        self.viewModel.items
            .mapTo(())
            .subscribe(onNext: { [weak self] in
                self?.refreshHeader?.endRefreshing()
            })
            .disposed(by: disposeBag)

		self.viewModel.totalMoneyInfo
            .map { $0.0 }
            .bind(to: self.bottomToolbar.rx.money)
            .disposed(by: disposeBag)

        self.viewModel.totalItemCount
            .bind(to: self.bottomToolbar.rx.itemCount)
            .disposed(by: disposeBag)

        self.viewModel.totalMoneyInfo
            .bind(to: self.bottomTipView.rx.shipInfo)
            .disposed(by: disposeBag)

        // 确认按钮是否允许点击
        self.viewModel.totalItemCount
            .map { $0 > 0 }
            .bind(to: self.bottomToolbar.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.viewModel.totalItemCount
            .map { $0 > 0 }
            .bind(to: self.bottomToolbar.rx.isNextButtonEnable)
            .disposed(by: disposeBag)

        // 确认按钮点击
        self.bottomToolbar.rx.nextButtonTap
            .withLatestFrom(self.viewModel.confirmItemsIds)
            .subscribe(onNext: { [weak self] orderIds in
                guard let strongself = self else { return }

                // 找出选中的 collectionId
                var collectionIds: [String] = []
                orderIds.forEach { orderId in
                    if let collection = strongself.collectionIdsDic[orderId] {
                        collectionIds.append(collection.key)
                    }
                }

                let vc = ConfirmDeliveryViewController(style: .eggProduct, orderIds: orderIds, collectionIds: collectionIds)
                strongself.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        // 全选按钮点击
        self.bottomToolbar.rx.selectAllButtonTap
            .asDriver()
            .withLatestFrom(self.viewModel.isSelectedAll.asDriver())
            .map { !$0 }
            .drive(self.viewModel.selectedAllSubject)
        	.disposed(by: disposeBag)

        self.viewModel.showSelectionPopup
            .subscribe(onNext: { pairs in
                self.presentCollectionSelection(pairs: pairs)
            })
        	.disposed(by: disposeBag)
    }
    
    @objc func titleButtonClick() {
        dropDownView.isHidden = !dropDownView.isHidden
        if !dropDownView.isHidden {
            navBar.backgroundColor = .white
        }
        let img = dropDownView.isHidden ? "game_record_arrow_up" : "game_record_arrow_down"
        arrowIv.image = UIImage(named: img)
    }

    func presentCollectionSelection(pairs: [(EggProduct, IndexPath)]) {
        guard let first = pairs.first else { return }
        self.currentSnackSelectionCell = self.tableView.cellForRow(at: first.1) as? DeliveryTableViewCell

        let collection = self.collectionIdsDic[first.0.orderId!]
        let vc = CollectionSelectionViewController(product: first.0, indexPath: first.1, cachedCollection: collection)
        vc.delegate = self
        vc.completionBlock = {

            let copy = pairs
            let dropFirst = copy.dropFirst()
            if !dropFirst.isEmpty {
                self.presentCollectionSelection(pairs: Array(dropFirst))
            }
        }

        UIView.transition(with: self.view, duration: 0.5, options: UIView.AnimationOptions.curveLinear, animations: {
            self.addChild(vc)
            vc.view.frame = self.view.bounds
            self.view.addSubview(vc.view)
        }, completion: { finish in

        })
    }
}

extension DeliveryViewController: CollectionSelectionDelegate {
    func didSelected(collection: EggProduct.Collection, from product: EggProduct, indexPath: IndexPath) {
        self.currentSnackSelectionCell?.iv.gas_setImageWithURL(collection.image)

        self.collectionIdsDic[product.orderId!] = collection

        self.viewModel.manualSelectedSubject.onNext((product, indexPath))
    }
}

extension DeliveryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY <= 0 { // 下拉
            if dropDownView.isHidden {
                navBar.backgroundColor = .new_backgroundColor
            }
        } else { // 上拉
            navBar.backgroundColor = .white
        }
    }
}

extension DeliveryViewController: GameRecordDropDownViewDelegate {
    func didButtonClick(index: Int) {
        let type = self.types[index].type
        if let IntType = Int(type) {
            self.viewModel.selectedTypeTrigger.onNext(IntType)
        }
    }
}
