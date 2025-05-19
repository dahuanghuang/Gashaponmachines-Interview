// 合成详情页
import UIKit
import RxCocoa
import RxDataSources
import RxSwift

enum CompositionDetailSectionModel {
    case material(items: [ComposeDetail])
}

extension CompositionDetailSectionModel: SectionModelType {
    typealias Item = ComposeDetail

    var items: [ComposeDetail] {
        switch self {
        case .material(items: let items):
            return items.map { $0 }
        }
    }

    init(original: CompositionDetailSectionModel, items: [ComposeDetail]) {
        self = .material(items: items)
    }
}

private let CompositionDetailTableCellIdentifier = "CompositionDetailTableCellIdentifier"

class CompositionDetailViewController: BaseViewController {

    var vm: CompositionDetailViewModel

    init(composePathId: String) {
        self.vm = CompositionDetailViewModel(composePathId: composePathId)
        super.init(nibName: nil, bundle: nil)
    }

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.rowHeight = 12 + 20 + 12 + 115
        tv.estimatedSectionHeaderHeight = 16
        tv.estimatedSectionFooterHeight = 16
        tv.register(CompositionDetailTableCell.self, forCellReuseIdentifier: CompositionDetailTableCellIdentifier)
        return tv
    }()

    let headerView = CompositionDetailTableHeaderView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: CompositionDetailTableHeaderView.height))

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "合成详情"
        self.vm.viewWillAppearTrigger.onNext(())

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
//		tableView.backgroundColor = .qu_cyanBlue
        tableView.backgroundColor = UIColor(hex: "ffe6ac")
        tableView.tableHeaderView = headerView
    }

    override func bindViewModels() {
        super.bindViewModels()

        let datasources = RxTableViewSectionedReloadDataSource<CompositionDetailSectionModel>(
            configureCell: { [weak self] (ds, tv, ip, _) in
                let cell: CompositionDetailTableCell = tv.dequeueReusableCell(withIdentifier: CompositionDetailTableCellIdentifier) as! CompositionDetailTableCell
                let detail = ds[ip]
                cell.configureWith(detail: detail)
                cell.delegate = self
                return cell
        })

        self.vm.envelope
            .map { $0.description }
            .subscribe(onNext: { [weak self] des in
                let footerView = CompositionDetailTableFooterView(text: des)
                let height = des.heightOfString(usingFont: UIFont.withPixel(24)) + 24 + 48
                footerView.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: height)
                self?.tableView.tableFooterView = footerView
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.vm.details
            .map { $0.map { CompositionDetailSectionModel.material(items: [$0]) }}
            .bind(to: tableView.rx.items(dataSource: datasources))
            .disposed(by: disposeBag)

        self.vm.envelope
        	.bind(to: self.headerView.rx.envelope)
        	.disposed(by: disposeBag)

        self.vm.envelope
            .map { $0.announcements }
            .bind(to: self.headerView.rx.announcements)
        	.disposed(by: disposeBag)

        self.vm.composeResult
            .subscribe(onNext: { _ in
                HUD.shared.dismiss()
                HUD.success(second: 2, text: "合成成功", completion: nil)
            })
        	.disposed(by: disposeBag)

        self.vm.lockResult
            .subscribe(onNext: { [weak self] _ in
                HUD.shared.dismiss()
                HUD.success(second: 2, text: "锁定成功") {
                    self?.vm.viewWillAppearTrigger.onNext(())
                }
            })
            .disposed(by: disposeBag)

        self.vm.error
            .subscribe(onNext: { env in
                HUD.shared.dismiss()
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)

        self.headerView.rx.composeAction
            .asDriver()
            .do(onNext: { _ in
                HUD.shared.persist(text: "请稍后...")
            })
            .drive(self.vm.composeButtonTap)
        	.disposed(by: disposeBag)

        self.headerView.rx.switchToDetailAction
            .asDriver()
            .drive(onNext: { _ in
                self.navigationController?.pushViewController(CompositionDetailIntroImagesViewController(introImages: self.headerView.introImages), animated: true)
            })
            .disposed(by: disposeBag)
    }

//    @objc func lock(orderIds: [String]) {
//        let confirmed = AppEnvironment.userDefault.bool(forKey: CompositionDetailPopViewController.userDefaultPopConfirmKey)
//        if confirmed {
//            self.vm.lockButtonTap.onNext(orderIds)
//        } else {
//            let vc = CompositionDetailPopViewController()
//            vc.modalPresentationStyle = .overFullScreen
//            vc.modalTransitionStyle = .crossDissolve
//            vc.lockButton.rx.tap.asDriver()
//                .drive(onNext: { [weak self] in
//                    self?.vm.lockButtonTap.onNext(orderIds)
//                })
//                .disposed(by: vc.disposeBag)
//            self.present(vc, animated: true, completion: nil)
//        }
//    }

}

extension CompositionDetailViewController: CompositionDetailTableCellDelegate {

//    func tableCellLockButtonTapped(orderIds: [String]) {
//        self.lock(orderIds: orderIds)
//    }

    func tableCellFindMaterialButtonTapped(notice: String, action: String) {
        let popVc = CompositionDetailPopViewController(notice: notice, action: action)
        popVc.modalPresentationStyle = .overFullScreen
        popVc.modalTransitionStyle = .crossDissolve
        self.present(popVc, animated: true, completion: nil)
    }
}

class CompositionDetailTableSectionView: UIView {

    private var corners: UIRectCorner

    private let view = UIView.withBackgounrdColor(UIColor(hex: "fff5de")!)

    init(corners: UIRectCorner) {
        self.corners = corners
        super.init(frame: .zero)

        self.backgroundColor = UIColor(hex: "ffe6ac")

        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
			make.left.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-16)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

    	view.roundCorners(corners, radius: 8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompositionDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return CompositionDetailTableSectionView(corners: [.topLeft, .topRight])
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 16
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == self.vm.details.value.count - 1 {
            return CompositionDetailTableSectionView(corners: [.bottomLeft, .bottomRight])
        } else {
            return CompositionDetailTableSectionView(corners: [])
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }

    // https://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = .zero
        }
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.responds(to: #selector(setter: UITableViewCell.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        // Explictly set your cell's layout margins
        if cell.responds(to: #selector(setter: UITableViewCell.layoutMargins)) {
            cell.layoutMargins = .zero
        }
    }
}
