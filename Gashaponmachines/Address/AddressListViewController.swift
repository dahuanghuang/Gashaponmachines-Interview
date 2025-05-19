import UIKit
import RxDataSources
import MJRefresh

private let AddressListTableViewCellReusableIdentifier = "AddressListTableViewCellReusableIdentifier"

class AddressListViewController: BaseViewController, Refreshable {
    

    var refreshHeader: MJRefreshHeader?

    let viewModel = AddressListViewModel()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .new_backgroundColor
        tv.emptyDataSetDataSource = self
        tv.emptyDataSetDelegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 110
        tv.register(AddressListTableViewCell.self, forCellReuseIdentifier: AddressListTableViewCellReusableIdentifier)
        return tv
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        viewModel.refreshTrigger.onNext(())
    }

    let bottomView = SingleButtonBottomView(title: "+ 新增地址")
    
    let navBar = CustomNavigationBar()
    
    let locationIv = UIImageView(image: UIImage(named: "address_location_logo"))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .new_backgroundColor
        
        navBar.backgroundColor = .new_backgroundColor
        navBar.title = "我的地址"
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }

        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(60+Constants.kScreenBottomInset)
            make.bottom.equalToSuperview()
        }

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(bottomView.snp.top)
        }
    
        tableView.addSubview(locationIv)
        locationIv.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(Constants.kScreenWidth-68)
            make.width.equalTo(56)
            make.height.equalTo(44)
        }

        refreshHeader = initRefreshHeader(.index, scrollView: tableView) { [weak self] in
            self?.viewModel.refreshTrigger.onNext(())
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: AddressListTableViewCellReusableIdentifier, cellType: AddressListTableViewCell.self)) { [weak self] (_, address, cell) in
                cell.configureWith(address: address)
                cell.defaultButton.rx.tap
                    .asDriver()
                    .map { address.addressId }
                    .drive(onNext: { [weak self] in
                        self?.viewModel.setDefaultTrigger.onNext($0)
                    })
                    .disposed(by: cell.rx.reuseBag)
                cell.editAddressButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        let vc = AddressEditorViewController(addressId: address.addressId)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    })
                    .disposed(by: cell.rx.reuseBag)
            }
    		.disposed(by: disposeBag)

        self.bottomView.rx.buttonTap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.pushViewController(AddressEditorViewController(addressId: nil), animated: true)
        	})
            .disposed(by: disposeBag)

//        self.tableView.rx.modelSelected(DeliveryAddress.self)
//            .asDriver()
//            .drive(onNext: { [weak self] address in
//                self?.navigationController?.pushViewController(AddressEditorViewController(addressId: address.addressId), animated: true)
//            })
//            .disposed(by: disposeBag)

        self.viewModel.setDefaultResult
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { success in
                if success {
                    HUD.success(second: 2, text: "设置成功") { [weak self] in
                        self?.viewModel.refreshTrigger.onNext(())
                    }
                } else {
                    HUD.showError(second: 2, text: "未知错误, 请稍后再试", completion: nil)
                }
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

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)
    }
}

extension AddressListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY <= 0 { // 下拉
            navBar.backgroundColor = .new_backgroundColor
            locationIv.isHidden = false
        } else { // 上拉
            navBar.backgroundColor = .white
            locationIv.isHidden = true
        }
    }
}
