import UIKit

class HomeCouponSignPopViewController: BaseViewController {

    let viewModel = HomeSignViewModel()

    var coupons: [PopMenuSignCoupon]!

    var currentIndexPath: IndexPath?

    let signButton = UIButton()

    let gradientLayer = CAGradientLayer()

    init(coupons: [PopMenuSignCoupon]) {
        super.init(nibName: nil, bundle: nil)
        self.coupons = coupons
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.rowHeight = 116
        tv.dataSource = self
        tv.delegate = self
        tv.register(SignInTableViewCell.self, forCellReuseIdentifier: SignInTableViewCellId)
        return tv
    }()

    fileprivate func setupView() {
        self.view.backgroundColor = .clear

        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(Constants.kScreenWidth)
            make.height.equalTo(484)
            make.center.equalTo(blackView)
        }

        // 顶部标题
        let titleView = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(55)
        }

        let titleIv = UIImageView(image: UIImage(named: "home_sign_headline"))
        titleView.addSubview(titleIv)
        titleIv.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        // 中间商品
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-96)
        }

        // 底部签到
        let bottomView = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(96)
        }

        signButton.isEnabled = false
        signButton.layer.cornerRadius = 24
        signButton.layer.masksToBounds = true
        signButton.addTarget(self, action: #selector(signButtonClick), for: .touchUpInside)
        signButton.setTitle("签到", for: .normal)
        signButton.setTitleColor(.qu_black, for: .normal)
        signButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        signButton.backgroundColor = .clear
        bottomView.addSubview(signButton)
        signButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(48)
            make.width.equalTo(280)
        }

        gradientLayer.frame = CGRect(x: 0, y: 0, width: 280, height: 48)
        gradientLayer.colors = [UIColor.qu_lightGray.cgColor, UIColor.qu_lightGray.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        signButton.layer.addSublayer(gradientLayer)

        signButton.bringSubviewToFront(signButton.titleLabel!)

        // 关闭按钮
        let closeIv = UIImageView(image: UIImage(named: "home_sign_close"))
        closeIv.isUserInteractionEnabled = true
        blackView.addSubview(closeIv)
        closeIv.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(40)
        }

        let closeButton = UIButton()
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(closeButtonClick), for: .touchUpInside)
        closeIv.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func setSignButtonEnable() {
        if !signButton.isEnabled {
            signButton.isEnabled = true
            gradientLayer.colors = [UIColor(hex: "fff1e1")!.cgColor, UIColor(hex: "ffd9b0")!.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
    }

    @objc func signButtonClick() {
        guard let index = currentIndexPath?.row else {
            HUD.showError(second: 1.0, text: "还没有选择优惠券哦", completion: nil)
            return
        }
        self.viewModel.requestSignIn.onNext(coupons[index].couponTemplateId)
    }

    @objc func closeButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }

    func dismissVc() {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .HomeSignInSuccess, object: nil)
        })
    }

    override func bindViewModels() {
        viewModel.signInResult
            .subscribe(onNext: { [weak self]_ in
                self?.dismissVc()
            }).disposed(by: disposeBag)

        viewModel.error
            .subscribe(onNext: { _ in
                HUD.showError(second: 2.0, text: "网络错误, 签到失败", completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension HomeCouponSignPopViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SignInTableViewCellId, for: indexPath) as! SignInTableViewCell
        cell.config(with: coupons[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let previousIndexPath = currentIndexPath, indexPath.row != previousIndexPath.row {

            let previousSelectCell = tableView.cellForRow(at: previousIndexPath) as! SignInTableViewCell
            previousSelectCell.isSelect = false
        }

        let currentSelectCell = tableView.cellForRow(at: indexPath) as! SignInTableViewCell
        currentSelectCell.isSelect = true

        self.currentIndexPath = indexPath

        self.setSignButtonEnable()
    }
}

let SignInTableViewCellId = "SignInTableViewCellId"

class SignInTableViewCell: UITableViewCell {

    var isSelect: Bool = false {
        didSet {
            if isSelect {
                self.lineIv.image = UIImage(named: "home_sign_line_select")
                self.bgView.backgroundColor = UIColor(hex: "fff45c")
                self.selectBtn.isHidden = true
                self.selectedIv.isHidden = false
            } else {
                self.lineIv.image = UIImage(named: "home_sign_line_normal")
                self.bgView.backgroundColor = UIColor(hex: "f5f4f2")
                self.selectBtn.isHidden = false
                self.selectedIv.isHidden = true
            }
        }
    }

    let selectBtn = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "选择", fontSize: 24)

    let selectedIv = UIImageView(image: UIImage(named: "home_sign_select_btn"))

    // 背景
    let bgView = UIView()

    // 商品图片
    let iconIv = UIImageView()

    // 分割线
    let lineIv = UIImageView(image: UIImage(named: "home_sign_line_normal"))

    // 标题
    let titleLb = UILabel.with(textColor: .qu_black, fontSize: 28)

    // 价格
    let priceLb = UILabel.with(textColor: .qu_black, fontSize: 24)

    // 优惠价
    let discountPriceLb = UILabel.with(textColor: .qu_black, boldFontSize: 46)

    // 优惠价格提示
    let descLb = UILabel.with(textColor: .qu_black, fontSize: 20)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.backgroundColor = .white

        bgView.backgroundColor = UIColor(hex: "f5f4f2")
        bgView.layer.cornerRadius = 8
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalToSuperview()
            make.bottom.equalTo(-16)
        }

        bgView.addSubview(iconIv)
        iconIv.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.size.equalTo(100)
        }

        bgView.addSubview(lineIv)
        lineIv.snp.makeConstraints { (make) in
            make.right.equalTo(-80)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(12)
        }

        titleLb.numberOfLines = 0
        bgView.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.left.equalTo(iconIv.snp.right)
            make.top.equalTo(15)
            make.right.equalTo(lineIv.snp.left)
        }

        bgView.addSubview(priceLb)
        priceLb.snp.makeConstraints { (make) in
            make.left.equalTo(titleLb)
            make.bottom.equalTo(-15)
        }

        discountPriceLb.textAlignment = .center
        bgView.addSubview(discountPriceLb)
        discountPriceLb.snp.makeConstraints { (make) in
            make.left.equalTo(lineIv.snp.right)
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview()
        }

        descLb.textAlignment = .center
        bgView.addSubview(descLb)
        descLb.snp.makeConstraints { (make) in
            make.left.right.equalTo(discountPriceLb)
            make.top.equalTo(discountPriceLb.snp.bottom)
        }

        selectBtn.isUserInteractionEnabled = false
        bgView.addSubview(selectBtn)
        selectBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-15)
            make.centerX.equalTo(descLb)
            make.height.equalTo(25)
            make.width.equalTo(45)
        }

        selectedIv.isHidden = true
        bgView.addSubview(selectedIv)
        selectedIv.snp.makeConstraints { (make) in
            make.center.equalTo(selectBtn)
            make.size.equalTo(25)
        }
    }

    func config(with coupon: PopMenuSignCoupon) {
        iconIv.gas_setImageWithURL(coupon.icon)

        titleLb.text = coupon.title

        if coupon.original != " " {
            let priceAttrM = NSMutableAttributedString(string: "价值 ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.qu_black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
            let priceAttr = NSAttributedString.init(string: coupon.original, attributes: [NSAttributedString.Key.foregroundColor: UIColor.qu_black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
            priceAttrM.append(priceAttr)
            priceLb.attributedText = priceAttrM
        }

        if coupon.original != " " {
            let discoutAttrM = NSMutableAttributedString(string: "¥", attributes: [NSAttributedString.Key.foregroundColor: UIColor.qu_black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
            let discoutAttr = NSAttributedString.init(string: coupon.promo, attributes: [NSAttributedString.Key.foregroundColor: UIColor.qu_black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 23)])
            discoutAttrM.append(discoutAttr)
            discountPriceLb.attributedText = discoutAttrM
        }

        descLb.text = coupon.promoNotice
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
