// 路由跳转界面
import UIKit
import RxDataSources
import MJRefresh

private let MallCategoryTableviewCelHeight: CGFloat = 100

private let MallCategoryTableviewCellReusableIdentifier = "MallCategoryTableviewCellReusableIdentifier"

class MallCategoryViewController: BaseViewController, Refreshable {

    init(categoryId: String) {
        self.viewModel = MallCategoryViewModel(categoryId: categoryId)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    private var viewModel: MallCategoryViewModel!

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.emptyDataSetDelegate = self
        tv.emptyDataSetDataSource = self
//        tv.layer.cornerRadius = 12
//        tv.layer.masksToBounds = true
        tv.backgroundColor = .clear
        tv.register(MallCategoryTableCell.self, forCellReuseIdentifier: MallCategoryTableviewCellReusableIdentifier)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor
        
        let navBar = CustomNavigationBar()
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + 44)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
        }

        refreshHeader = initRefreshHeader(.index, scrollView: tableView) { [weak self] in
            self?.viewModel.refreshTrigger.onNext(())
        }

        refreshHeader?.beginRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.refreshTrigger.onNext(())
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: MallCategoryTableviewCellReusableIdentifier, cellType: MallCategoryTableCell.self)) { (_, item, cell) in
                cell.configureWith(product: item)
            }
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
            	HUD.showErrorEnvelope(env: env)
        	})
        	.disposed(by: disposeBag)

        self.tableView.rx.modelSelected(MallProduct.self)
        	.asDriver()
            .map { $0.productId }
            .filterNil()
            .drive(onNext: { [weak self] productId in
                self?.navigationController?.pushViewController(MallDetailViewController.init(mallProductId: productId), animated: true)
            })
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
    }
}

extension MallCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MallCategoryTableviewCelHeight
    }
}
