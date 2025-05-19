import UIKit
import RxDataSources
import MJRefresh
import TBEmptyDataSet

class CouponViewController: BaseViewController, Refreshable {

    let viewModel: CouponViewModel!

    var refreshFooter: MJRefreshFooter?

    let footerView = CouponFooterView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 50))

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.tableFooterView = self.footerView
        tv.dataSource = self
        tv.delegate = self
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tv.register(CouponTableViewCell.self, forCellReuseIdentifier: CouponTableViewCellId)
        return tv
    }()
    
    /// 是否需要导航栏
    var isNeedNav: Bool!

    // MARK: - 初始化函数
    init(couponType: CouponType, isNeedNav: Bool? = true) {
        viewModel = CouponViewModel(couponType: couponType)
        super.init(nibName: nil, bundle: nil)
        self.isNeedNav = isNeedNav
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNeedNav {
            let navBar = CustomNavigationBar()
            navBar.title = "优惠券"
            navBar.setupRightButton(text: "记录", target: self, selector: #selector(jumpToRecordVc))
            view.addSubview(navBar)
            navBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
            }
            
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.equalTo(navBar.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
        }else {
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        self.viewModel.requestCoupon.onNext(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func jumpToRecordVc() {
        navigationController?.pushViewController(CouponRecordViewController(), animated: true)
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel.coupons
            .subscribe(onNext: { [weak self] env in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension CouponViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coupons.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CouponTableViewCellId, for: indexPath) as! CouponTableViewCell
        cell.configureWith(coupon: viewModel.coupons.value[indexPath.row], isSelect: false)
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return (Constants.kScreenWidth/4 - 6) + 8 + 12
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coupon = viewModel.coupons.value[indexPath.row]
        if let action = coupon.action {
            RouterService.route(to: action)
        }
    }
}
