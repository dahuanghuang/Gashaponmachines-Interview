import UIKit
import RxCocoa
import RxSwift

class CouponSelectPopViewController: BaseViewController {

    /// 选中优惠券回调
    public var selectCouponHandle: ((Coupon?) -> Void)?

    private let contentViewH = Constants.kScreenHeight * (2/3)

    private lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.tableHeaderView = self.headerView
        tv.tableFooterView = self.footerView
        tv.dataSource = self
        tv.delegate = self
        tv.register(CouponTableViewCell.self, forCellReuseIdentifier: CouponTableViewCellId)
        return tv
    }()

    /// 可用优惠券
    private var availCoupons: [Coupon]!
    /// 全部优惠券
    private var allCoupons: [Coupon]!
    /// 优惠券数据源
    private var coupons = [Coupon]()

    /// 头部视图
    private let headerView = CouponSelectHeaderView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: CouponSelectHeaderView.height))

    /// 尾部视图
    let footerView = CouponFooterView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 50))

    /// 优惠券类型选中
    private var segmentIndex = 0 {
        didSet {
            if segmentIndex == 0 {
                self.coupons = availCoupons
            } else {
                self.coupons = allCoupons
            }
            self.tableView.reloadData()
        }
    }
    /// 选中的优惠券
    private var selectCoupon: Coupon?

    /// 黑色遮罩
    private let blackView = UIView()
    /// 灰色内容背景
    private let contentView = UIView()
    /// 灰色遮罩
    private let maskView = UIView.withBackgounrdColor(.viewBackgroundColor)

    // MARK: - 初始化函数
    init(availCoupons: [Coupon], allCoupons: [Coupon], selectCoupon: Coupon?) {
        super.init(nibName: nil, bundle: nil)
        self.availCoupons = availCoupons
        self.allCoupons = allCoupons
        self.selectCoupon = selectCoupon
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 系统函数

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        self.segmentIndex = 0
    }

    func setupUI() {
        self.view.backgroundColor = .clear

        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.backgroundColor = .viewBackgroundColor
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.equalTo(contentViewH)
            make.left.right.equalToSuperview()
            make.top.equalTo(blackView.snp.bottom).offset(-contentViewH)
        }

        // 顶部标题
        let titleView = UIView.withBackgounrdColor(.white)
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "优惠券")
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        let closeIv = UIImageView(image: UIImage(named: "coupon_close"))
        titleView.addSubview(closeIv)
        closeIv.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(25)
        }

        let closeBtn = UIButton()
        closeBtn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        titleView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.height.equalToSuperview()
            make.width.equalTo(50)
        }

        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        maskView.isHidden = true
        contentView.addSubview(maskView)
        maskView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(12)
        }

        let confirmButton = UIButton()
        confirmButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmButton.setTitleColor(.qu_black, for: .normal)
        confirmButton.backgroundColor = UIColor(hex: "ffd712")
        confirmButton.layer.cornerRadius = 24
        confirmButton.layer.masksToBounds = true
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-12 - Constants.kScreenBottomInset)
            make.right.equalTo(-12)
            make.left.equalTo(12)
            make.height.equalTo(48)
        }
    }

    @objc func dismissVC() {

        contentView.snp.updateConstraints { make in
            make.top.equalTo(blackView.snp.bottom)
        }

        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.blackView.alpha = 0.0
        }) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func bindViewModels() {
        self.headerView.availButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.segmentIndex = 0
            })
            .disposed(by: disposeBag)

        self.headerView.allButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.segmentIndex = 1
            })
            .disposed(by: disposeBag)
    }
}

extension CouponSelectPopViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coupons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CouponTableViewCellId, for: indexPath) as! CouponTableViewCell

        let coupon = coupons[indexPath.row]
        var isSelect = false
        if let selectId = selectCoupon?.couponId {
            isSelect = coupon.couponId == selectId ? true : false
        }
        cell.configureWith(coupon: coupon, isSelect: isSelect)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let coupon = coupons[indexPath.row]

        if let canUse = coupon.canUse, canUse == "1" {
            if let selectCoupon = self.selectCoupon,
                selectCoupon.couponId == coupon.couponId { // 取消选中
                self.selectCoupon = nil
            } else { // 选中
                self.selectCoupon = coupon
            }
            tableView.reloadData()
            if let handle = selectCouponHandle {
                handle(self.selectCoupon)
            }
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return (Constants.kScreenWidth/4 - 6) + 8 + 12
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        maskView.isHidden = scrollView.contentOffset.y > 48 ? false : true
    }
}

class CouponSelectHeaderView: UIView {

    static let height: CGFloat = 60

    lazy var availButton: UIButton = {
        let btn = UIButton.with(title: "可使用", titleColor: .qu_black, fontSize: 28)
        btn.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        return btn
    }()

    lazy var allButton: UIButton = {
        let btn = UIButton.with(title: "全部优惠券", titleColor: .qu_black, fontSize: 28)
        btn.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
        btn.backgroundColor = UIColor(hex: "e6e6e6")
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        return btn
    }()

    var selectButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear

        let availBtnW = availButton.titleLabel!.text!.sizeOfString(usingFont: UIFont.withPixel(28)).width + 24
        self.addSubview(availButton)
        availButton.snp.makeConstraints { make in
            make.left.top.equalTo(12)
            make.width.equalTo(availBtnW)
            make.height.equalTo(36)
        }

        let allBtnW = allButton.titleLabel!.text!.sizeOfString(usingFont: UIFont.withPixel(28)).width + 24
        self.addSubview(allButton)
        allButton.snp.makeConstraints { make in
            make.left.equalTo(availButton.snp.right).offset(12)
            make.width.equalTo(allBtnW)
            make.top.height.equalTo(availButton)
        }

        self.selectButton = self.availButton
    }

    @objc func buttonClick(button: UIButton) {

        if selectButton.isEqual(button) { return }

        button.backgroundColor = .white
        self.selectButton.backgroundColor = UIColor(hex: "e6e6e6")
        self.selectButton = button
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
