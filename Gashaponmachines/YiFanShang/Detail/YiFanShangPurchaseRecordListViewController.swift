import UIKit
import RxDataSources
import MJRefresh
import TBEmptyDataSet

private let YiFanShangPurchaseRecordListTableViewCellReusableIdentifier = "YiFanShangPurchaseRecordListTableViewCellReusableIdentifier"

class YiFanShangPurchaseRecordListViewController: BaseViewController, Refreshable {

    init(onePieceTaskRecordId: String) {
        self.viewModel = YiFanShangPurchaseRecordListViewModel(onePieceTaskRecordId: onePieceTaskRecordId)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var viewModel: YiFanShangPurchaseRecordListViewModel

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

//    static let cellHeight = 16 + 8 + 16 + 16 + UIFont.withPixel(28).lineHeight + UIFont.withPixel(24).lineHeight + UIFont.withPixel(20).lineHeight

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.emptyDataSetDelegate = self
        tv.emptyDataSetDataSource = self
        tv.estimatedRowHeight = UITableView.automaticDimension
        tv.register(YiFanShangPurchaseRecordListTableViewCell.self, forCellReuseIdentifier: YiFanShangPurchaseRecordListTableViewCellReusableIdentifier)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor
        
        let navBar = CustomNavigationBar()
        navBar.title = "我的参与记录"
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
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

        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: YiFanShangPurchaseRecordListTableViewCellReusableIdentifier, cellType: YiFanShangPurchaseRecordListTableViewCell.self)) { (_, item, cell) in
                cell.configureWith(record: item)
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
            })
            .disposed(by: disposeBag)
    }
}

extension YiFanShangPurchaseRecordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
