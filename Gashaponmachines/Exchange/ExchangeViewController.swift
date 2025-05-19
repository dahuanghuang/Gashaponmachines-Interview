import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxOptional

private let ExchangeCollectionViewCellWidth = floor((Constants.kScreenWidth - 40) / 3)
let ExchangeCollectionViewCellHeight: CGFloat = 166
private let ExchangeCollectionViewCellReusableIdentifier = "ExchangeCollectionViewCellReusableIdentifier"
class ExchangeViewController: BaseViewController {

    let bottomView = ExchangeBottomView()

    var viewModel: ExchangeViewModel!

    var allProducts = [([EggProduct]?, String)]()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: ExchangeCollectionViewCellWidth, height: ExchangeCollectionViewCellHeight)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.allowsMultipleSelection = true
        cv.emptyDataSetDelegate = self
        cv.emptyDataSetDataSource = self
        cv.backgroundColor = .new_backgroundColor
        cv.register(ExchangeCollectionViewCell.self, forCellWithReuseIdentifier: ExchangeCollectionViewCellReusableIdentifier)
        return cv
    }()

    var dataSource: RxCollectionViewSectionedReloadDataSource<EggExchangeListEnvelope>?

    init(type: EggProductType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = ExchangeViewModel(type: type)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
		self.view.backgroundColor = .new_backgroundColor
        
        let navBar = CustomNavigationBar()
        navBar.backgroundColor = .new_backgroundColor
        navBar.title = "换取蛋壳"
        navBar.setupRightButton(text: "明细", target: self, selector: #selector(exchangeRecord))
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.height.equalTo(60 + Constants.kScreenBottomInset)
            make.bottom.equalToSuperview()
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.equalTo(view)
            make.bottom.equalTo(bottomView.snp.top)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        viewModel.viewWillAppearTrigger.onNext(())
    }

    override func bindViewModels() {
        super.bindViewModels()

        let dataSource = RxCollectionViewSectionedReloadDataSource<EggExchangeListEnvelope>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withReuseIdentifier: ExchangeCollectionViewCellReusableIdentifier, for: ip) as! ExchangeCollectionViewCell
                cell.configureWith(egg: item)
                cell.bind(to: self.viewModel.selectionState.asObservable(), as: item, indexPath: ip)

                // 详情点击
                cell.button.rx.tap
                    .asObservable()
                    .withLatestFrom(self.viewModel.selectionState.asObservable().filter {$0.count > ip.row}.map { $0[ip.row] })
                    .subscribe(onNext: { [weak self] selectedProducts in
                        guard let strongSelf = self else { return }
                        // 拿到之前选择过的物品
                        let vc = ExchangeDetailViewController(allProducts: item.products,
                                                              selectedProducts: selectedProducts,
                                                              title: item.title,
                                                              subTitle: item.subTitle)
                        vc.modalPresentationStyle = .overFullScreen

                        vc.viewModel.submit
                            .map {
                                ExchangeSelectionEvent.innerSelection(indexPath: ip, products: Array($0))
                        	}
                        	.drive(strongSelf.viewModel.selection)
                        	.disposed(by: vc.disposeBag)

                        strongSelf.present(vc, animated: false, completion: nil)
                    })
                    .disposed(by: cell.rx.reuseBag)
                return cell
        	})

        self.dataSource = dataSource

        self.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.envelope
            .drive(self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // 默认的选中状态
        // [([EggProduct]?, String), ([EggProduct]?, String), ([EggProduct]?, String), ....]
        self.viewModel.allProducts
            .subscribe(onNext: { [weak self] products in
                self?.allProducts = products

                // 选中某些蛋
                if let types = self?.viewModel.noneSelectedTypes.value {
                    for (index, product) in products.enumerated() {
                        if let array = product.0, !types.contains(product.1) {
                            self?.viewModel.selection
                                .onNext(ExchangeSelectionEvent.outterSelection(indexPath: IndexPath(row: index, section: 0), products: array))
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        Observable
            .zip(
                self.collectionView.rx.itemSelected,
                self.collectionView.rx.modelSelected(Egg.self)
            )
            .map { ExchangeSelectionEvent.outterSelection(indexPath: $0.0, products: $0.1.products) }
            .bind(to: self.viewModel.selection)
            .disposed(by: disposeBag)

        Observable
            .zip(
                self.collectionView.rx.itemDeselected,
                self.collectionView.rx.modelDeselected(Egg.self)
            )
            .map { ExchangeSelectionEvent.outterSelection(indexPath: $0.0, products: $0.1.products) }
            .bind(to: self.viewModel.selection)
            .disposed(by: disposeBag)

        self.viewModel.totalValue
            .bind(to: self.bottomView.rx.totalCount)
            .disposed(by: disposeBag)

        self.viewModel.totalValue
            .map { $0 > 0 }
            .asDriver(onErrorJustReturn: false)
            .drive(self.bottomView.exchangeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.viewModel.totalValue
            .map { $0 > 0 }
            .bind(to: self.bottomView.rx.isExchangeButtonEnable)
            .disposed(by: disposeBag)

        // 换取点击
        self.bottomView.exchangeButton.rx.tap
            .asDriver()
            .withLatestFrom(self.viewModel.exchangeInfo)
            .drive(onNext: { [weak self] info in
                let vc = ExchangeConfrimViewController(info: info)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.exchangeButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.dismiss(animated: true, completion: {
                            // 刷新蛋槽
                            NotificationCenter.default.post(name: .refreshEggProduct, object: nil)
                            self?.viewModel.exchangeButtonSubject.onNext(())
                            HUD.shared.persist(text: "兑换中")
                        })
                	})
                	.disposed(by: vc.disposeBag)
                self?.present(vc, animated: true, completion: nil)
            })
        	.disposed(by: disposeBag)

        // 兑换结果
        self.viewModel.exchangeResult
            .drive(onNext: { [weak self] env in
                HUD.shared.dismiss()
                if env.failProducts == nil {
                    self?.cleanAllState()
                    self?.viewModel.viewWillAppearTrigger.onNext(())
                    
                    let vc = ExchangeSuccessViewController()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self?.present(vc, animated: true, completion: nil)
                }
        	})
        	.disposed(by: disposeBag)

        /// 错误信息
        self.viewModel.error
        	.subscribe(onNext: { env in
                HUD.shared.dismiss()
                HUD.showErrorEnvelope(env: env)
            })
        	.disposed(by: disposeBag)

    }

    /// 清除所有选中状态
    func cleanAllState() {
        for index in 0..<self.allProducts.count {
            self.viewModel.selection
                .onNext(ExchangeSelectionEvent.outterSelection(indexPath: IndexPath(row: index, section: 0), products: [EggProduct]()))
        }
    }

    /// 兑换明细
    @objc func exchangeRecord() {
        self.navigationController?.pushViewController(ExchangeRecordViewController(), animated: true)
    }
}

extension ExchangeViewController: UICollectionViewDelegate {}
