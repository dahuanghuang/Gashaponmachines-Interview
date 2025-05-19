// 路由跳转界面
import UIKit
import RxSwift
import RxDataSources
import MJRefresh

private let MallCollectionTableviewCellReusableIdentifier = "MallCategoryTableviewCellReusableIdentifier"

class MallCollectionViewController: BaseViewController, Refreshable {

    init(mallProductId: String) {
        self.viewModel = MallCollectionViewModel(mallProductId: mallProductId)
        super.init(nibName: nil, bundle: nil)
//        self.navigationItem.title = title
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    private var viewModel: MallCollectionViewModel!

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.estimatedRowHeight = MallCollectionTableViewCell.Width + 12 + 8 + 15 + 16 + UIFont.heightOfPixel(28)
        tv.backgroundColor = .white
//        tv.emptyDataSetDelegate = self
//        tv.emptyDataSetDataSource = self
        tv.layer.cornerRadius = 8
        tv.layer.masksToBounds = true
        tv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        tv.register(MallCollectionTableViewCell.self, forCellReuseIdentifier: MallCollectionTableviewCellReusableIdentifier)
        return tv
    }()
    
    
    let navBar = CustomNavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .qu_red
        
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
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

//        self.viewModel.title
//            .bind(to: navigationItem.rx.title)
//            .disposed(by: disposeBag)
        
        self.viewModel.title.subscribe(onNext: { [weak self] title in
            self?.navBar.title = title
        }).disposed(by: disposeBag)


        self.viewModel.items
            .asDriver()
            .map { $0.chunks(2) }
            .drive(self.tableView.rx.items(cellIdentifier: MallCollectionTableviewCellReusableIdentifier, cellType: MallCollectionTableViewCell.self)) { [weak self] (row, item, cell) in
                guard let strongself = self else { return }
                cell.configureWith(products: item)
                cell.leftView.delegate = strongself
                cell.rightView.delegate = strongself
            }
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
                self?.refreshFooter?.endRefreshing()
                self?.setupFooterIfNotExist()
            })
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)
    }

    private func setupFooterIfNotExist() {
        if self.tableView.mj_footer == nil {
            self.refreshFooter = initRefreshFooter(.index, scrollView: tableView) {
                if !self.viewModel.isEnd.value {
                    self.viewModel.loadNextPageTrigger.onNext(())
                } else {
                    self.refreshFooter?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
}

extension MallCollectionViewController: MallTableViewCellViewDelegate {

    func switchToMallProductDetail(productId: String) {
        self.navigationController?.pushViewController(MallDetailViewController(mallProductId: productId), animated: true)
    }
}

extension MallCollectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}
