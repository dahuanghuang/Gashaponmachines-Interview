import RxCocoa
import RxSwift

private let InviteFriendListTableCellReusIdentifier = "InviteFriendListTableCellReusIdentifier"

final class InviteFriendListViewController: BaseViewController {

    let viewModel = InviteFriendListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "我的好友"
        self.view.backgroundColor = .qu_yellow

        let containerView = UIView.withBackgounrdColor(.qu_yellow)
        containerView.layer.cornerRadius = 4
        containerView.layer.masksToBounds = true
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view.safeArea.bottom).offset(-24)
        }

        containerView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshTrigger.onNext(())
    }

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .qu_yellow
        tv.register(InviteTableViewCell.self, forCellReuseIdentifier: InviteFriendListTableCellReusIdentifier)
        return tv
    }()

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: InviteFriendListTableCellReusIdentifier, cellType: InviteTableViewCell.self)) { (_, item, cell) in
				cell.configureWith(friend: item)
            }
            .disposed(by: disposeBag)
    }
}

extension InviteFriendListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
}
