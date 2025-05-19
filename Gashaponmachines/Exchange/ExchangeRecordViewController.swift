import UIKit
import RxDataSources
import MJRefresh

private let ExchangeRecordTableViewCellReusableIdentifier = "ExchangeRecordTableViewCellReusableIdentifier"

class ExchangeRecordViewController: BaseViewController, Refreshable {

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    var viewModel: ExchangeRecordViewModel = ExchangeRecordViewModel()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.emptyDataSetDelegate	= self
        tv.emptyDataSetDataSource = self
        tv.delegate = self
        tv.backgroundColor = .new_backgroundColor
        tv.rowHeight = 82
        tv.register(ExchangeRecordTableViewCell.self, forCellReuseIdentifier: ExchangeRecordTableViewCellReusableIdentifier)
        return tv
    }()

    let navBar = CustomNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor
        
        navBar.backgroundColor = .new_backgroundColor
        navBar.title = "蛋壳明细"
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
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

        self.viewModel.items
            .asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: ExchangeRecordTableViewCellReusableIdentifier, cellType: ExchangeRecordTableViewCell.self)) { [weak self] (index, item, cell) in
                guard let self = self else { return }
            	cell.configureWith(record: item, isFirst: index == 0, isLast: index == self.viewModel.items.value.count-1)
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

extension ExchangeRecordViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY <= 0 { // 下拉
            navBar.backgroundColor = .new_backgroundColor
        } else { // 上拉
            navBar.backgroundColor = .white
        }
    }
}
