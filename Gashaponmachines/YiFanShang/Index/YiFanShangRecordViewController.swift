import UIKit
import RxDataSources
import MJRefresh
import TBEmptyDataSet

// 元气赏购买记录
private let YiFanShangRecordTableViewCellReusableIdentifier = "YiFanShangRecordTableViewCellReusableIdentifier"

class YiFanShangRecordViewController: BaseViewController, Refreshable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    var viewModel: YiFanShangRecordViewModel = YiFanShangRecordViewModel()

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.emptyDataSetDelegate = self
        tv.emptyDataSetDataSource = self
        tv.delegate = self
        tv.backgroundColor = .new_backgroundColor
        tv.rowHeight = 130
        tv.register(YiFanShangRecordTableViewCell.self, forCellReuseIdentifier: YiFanShangRecordTableViewCellReusableIdentifier)
        return tv
    }()
    
    let navBar = CustomNavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor
        
        navBar.backgroundColor = .new_backgroundColor
        navBar.title = "元气赏购买记录"
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

        self.viewModel.items
            .asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: YiFanShangRecordTableViewCellReusableIdentifier, cellType: YiFanShangRecordTableViewCell.self)) { (_, item, cell) in
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

extension YiFanShangRecordViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY <= 0 { // 下拉
            navBar.backgroundColor = .new_backgroundColor
        } else { // 上拉
            navBar.backgroundColor = .white
        }
    }
}
