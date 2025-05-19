import RxDataSources
import RxSwift
import Tabman
import MJRefresh

extension Notification.Name {
    // 发货记录列表是否到顶部的通知(顶部颜色渐变控制)
    public static let DeliveryRecordContentPullScroll = Notification.Name("DeliveryRecordContentPullScroll")
}

private let DeliveryRecordTableViewCellReuseIdentifier = "DeliveryRecordTableViewCellReuseIdentifier"


class DeliveryRecordListViewController: BaseViewController, Refreshable {

    private var status: DeliveryStatus = .toBeDelivered
    
    /// 是否需要展示近一个月发货
    var isShowWorth = false
    
    var shipWorthEnvelope: ShipWorthEnvelope? {
        didSet {
            if let env = shipWorthEnvelope {
                self.isShowWorth = (env.shipCount != "0")
                self.tableview.reloadData()
            }
        }
    }

    init(status: DeliveryStatus) {
        self.status = status
        super.init(nibName: nil, bundle: nil)
        self.viewModel = DeliveryRecordViewModel(status: status)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var viewModel: DeliveryRecordViewModel!

    lazy var tableview: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.backgroundColor = .new_backgroundColor
        tv.emptyDataSetDataSource = self
        tv.emptyDataSetDelegate = self
        tv.register(DeliveryRecordTableViewCell.self, forCellReuseIdentifier: DeliveryRecordTableViewCellReuseIdentifier)
        return tv
    }()

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor

        view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        refreshHeader = initRefreshHeader(.index, scrollView: tableview) { [weak self] in
            self?.viewModel.refreshTrigger.onNext(())
            self?.viewModel.getShipWorthRequest.onNext(())
        }

        refreshHeader?.beginRefreshing()
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableview.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .asDriver()
            .drive(self.tableview.rx.items(cellIdentifier: DeliveryRecordTableViewCellReuseIdentifier, cellType: DeliveryRecordTableViewCell.self)) { (index, item, cell) in
                let isShow = (index == 0 && self.isShowWorth)
                cell.configureWith(info: item, status: self.status, isShow: isShow, shipWorth: self.shipWorthEnvelope)
            }
            .disposed(by: disposeBag)

        self.tableview.rx
            .modelSelected(ShipListEnvelope.ShipInfo.self)
            .asDriver()
            .drive(onNext: { [weak self] info in
                guard let strongself = self else { return }
                let vc = DeliveryRecordDetailViewController(shipId: info.shipId)
                strongself.navigationController?.pushViewController(vc, animated: true)
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
        
        self.viewModel.shipWorthEnvelope.subscribe(onNext: { [weak self] env in
            guard let sSelf = self else { return }
            sSelf.shipWorthEnvelope = env
        }).disposed(by: disposeBag)
    }
}

extension DeliveryRecordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && self.isShowWorth {
            return 162 + DeliveryRecordTableViewCell.imageViewWH + DeliveryRecordWorthView.height
        }else {
            return 74 + DeliveryRecordTableViewCell.imageViewWH + DeliveryRecordWorthView.height
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            NotificationCenter.default.post(name: .DeliveryRecordContentPullScroll, object: nil, userInfo: ["isPullTop": true])
        }else {
            NotificationCenter.default.post(name: .DeliveryRecordContentPullScroll, object: nil, userInfo: ["isPullTop": false])
        }
    }
}
