//import UIKit
//import RxDataSources
//import MJRefresh
//
//private let AddressListManagementTableViewCellReusableIdentifier = "AddressListManagementTableViewCellReusableIdentifier"
//
//class AddressListManagementViewController: BaseViewController, Refreshable {
//
//    var preSelectedAddressId: String?
//
//    init(preSelectedAddressId: String?) {
//        self.preSelectedAddressId = preSelectedAddressId
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    var refreshHeader: MJRefreshHeader?
//
//    let viewModel = AddressListViewModel()
//
//    lazy var tableView: BaseTableView = {
//        let tv = BaseTableView(frame: .zero, style: .grouped)
//        tv.emptyDataSetDataSource = self
//        tv.emptyDataSetDelegate = self
//        tv.register(AddressManagementTableViewCell.self, forCellReuseIdentifier: AddressListManagementTableViewCellReusableIdentifier)
//        return tv
//    }()
//
//    let bottomView = SingleButtonBottomView(backgroundColor: .qu_yellow, titleColor: .qu_black, title: "新增地址+")
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        viewModel.refreshTrigger.onNext(())
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.view.backgroundColor = .white
//        navigationItem.title = "选择地址"
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.barButtonItemWith(text: "管理", target: self, selector: #selector(goToAddressList))
//        self.view.addSubview(bottomView)
//        bottomView.snp.makeConstraints { make in
//            make.left.right.equalTo(self.view)
//            make.height.equalTo(60 + Constants.kScreenBottomInset)
//            make.bottom.equalToSuperview()
//        }
//
//        self.view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.top.left.right.equalTo(self.view)
//            make.bottom.equalTo(bottomView.snp.top)
//        }
//
//        refreshHeader = initRefreshHeader(.index, scrollView: tableView) { [weak self] in
//            self?.viewModel.refreshTrigger.onNext(())
//        }
//
//        refreshHeader?.beginRefreshing()
//    }
//
//    @objc func goToAddressList() {
//        self.navigationController?.pushViewController(AddressListViewController(), animated: true)
//    }
//
//    override func bindViewModels() {
//        super.bindViewModels()
//
//        self.tableView.rx.setDelegate(self)
//            .disposed(by: disposeBag)
//
//        self.viewModel.items
//            .asDriver()
//            .drive(self.tableView.rx.items(cellIdentifier: AddressListManagementTableViewCellReusableIdentifier, cellType: AddressManagementTableViewCell.self)) { [weak self] (_, address, cell) in
//
//                let isSelected = address.addressId == self?.preSelectedAddressId
//                cell.configureWith(address: address, isSelected: isSelected)
//                cell.defaultButton.rx.tap
//                    .asDriver()
//                    .map { _ in address.addressId }
//                    .drive(onNext: { [weak self] in
//                        self?.viewModel.setDefaultTrigger.onNext($0)
//                    })
//                    .disposed(by: cell.rx.reuseBag)
//            }
//            .disposed(by: disposeBag)
//
//        bottomView.rx.buttonTap
//            .asDriver()
//            .drive(onNext: { [weak self] in
//                self?.navigationController?.pushViewController(AddressEditorViewController(addressId: nil), animated: true)
//            })
//            .disposed(by: disposeBag)
//
//        self.tableView.rx.reachedBottom
//            .mapTo(())
//            .skipWhile { self.viewModel.items.value.isEmpty }
//            .bind(to: viewModel.loadNextPageTrigger)
//            .disposed(by: disposeBag)
//
//        self.viewModel.items
//            .mapTo(())
//            .subscribe(onNext: { [weak self] in
//                self?.refreshHeader?.endRefreshing()
//            })
//            .disposed(by: disposeBag)
//
//        self.viewModel.error
//            .subscribe(onNext: { env in
//                HUD.showErrorEnvelope(env: env)
//            })
//            .disposed(by: disposeBag)
//    }
//}
//
//extension AddressListManagementViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.001
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return nil
//    }
//}
