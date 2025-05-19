import RxSwift
import RxCocoa
import MJRefresh

class NotificationViewController: BaseViewController, Refreshable {

    private let NotificationTableViewCellReuseIdentifier = "NotificationTableViewCellReuseIdentifier"

    // 已读消息的集合
    static let NotificationReadNoticesUserDefaultKey = "NotificationReadNoticesUserDefaultKey"

    private let allReadButton = UIButton.with(title: "全部已读", titleColor: .new_middleGray, fontSize: 24)

    private let viewModel: NotificationViewModel = NotificationViewModel()

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tableview.reloadData()
    }

    lazy var tableview: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.backgroundColor = .new_backgroundColor
        tv.emptyDataSetDelegate = self
        tv.emptyDataSetDataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 70
//        tv.estimatedSectionHeaderHeight = InviteSectionView.Height
//        tv.estimatedSectionFooterHeight = 180+16+16
        tv.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCellReuseIdentifier)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .new_backgroundColor

        let nav = UIView.withBackgounrdColor(.clear)
        view.addSubview(nav)
        nav.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.right.equalTo(self.view)
            make.height.equalTo(Constants.kNavHeight)
        }

        let backButton = UIButton.with(imageName: "nav_back_black", target: self, selector: #selector(goback))
        nav.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(nav).offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "通知中心")
        nav.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        nav.addSubview(allReadButton)
        allReadButton.snp.makeConstraints { make in
            make.right.equalTo(nav).offset(-24)
            make.centerY.equalToSuperview()
        }

        view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.top.equalTo(nav.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }

        refreshHeader = initRefreshHeader(.index, scrollView: tableview) { [weak self] in
            self?.viewModel.refreshTrigger.onNext(())
        }

        refreshHeader?.beginRefreshing()
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.allReadButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] info in
                guard let vc = self?.allReadViewController() else { return }
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        self.tableview.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .asDriver()
            .drive(self.tableview.rx.items(cellIdentifier: NotificationTableViewCellReuseIdentifier, cellType: NotificationTableViewCell.self)) { (_, item, cell) in
                cell.configureWith(notification: item)
                cell.bind(to: self.viewModel.state, as: item.notificationId)
            }
            .disposed(by: disposeBag)

        self.tableview.rx.modelSelected(Notice.self)
        	.asDriver()
            .map { NotificationSelectionEvent.once($0.notificationId) }
        	.drive(self.viewModel.selection.asObserver())
        	.disposed(by: disposeBag)

        self.tableview.rx
            .modelSelected(Notice.self)
            .asDriver()
            .map { $0.action }
            .filterNil()
            .drive(onNext: { action in
            	RouterService.route(to: action)
            })
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showError(second: 2, text: env.msg, completion: nil)
            })
            .disposed(by: disposeBag)

        self.tableview.rx.reachedBottom
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

    @objc func goback() {
        self.navigationController?.popViewController(animated: true)
    }

    func allReadViewController() -> NotificationAllReadViewController {
        let vc = NotificationAllReadViewController()
        vc.confirmButton.rx.tap
        	.asDriver()
            .map { NotificationSelectionEvent.all }
            .drive(onNext: { event in
                self.viewModel.selection.onNext(event)
                vc.dismiss(animated: true, completion: nil)
            })
        	.disposed(by: vc.disposeBag)
        return vc
    }
}

extension NotificationViewController: UITableViewDelegate {

}
