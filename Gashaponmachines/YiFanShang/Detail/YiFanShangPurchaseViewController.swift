import Foundation
import RxKeyboard

extension Notification.Name {
    /// 一番赏购买成功通知
    static let yfsDetailPurchaseSeccess = Notification.Name("yfsDetailPurchaseSeccess")
}

class YiFanShangPurchaseViewController: BaseViewController {

    var purchaseViewModel: YiFanShangPurchaseViewModel!

    /// 刷新数据回调
    var refreshDataCallBack: (() -> Void)?

    /// 劵价格
    private var price: Int = 1

    /// 剩余元气值
    private var balance: Int = 0

    /// 减少按钮
    lazy var minButton: UIButton = {
        let btn = UIButton.with(imageName: "yfs_buy_min")
        btn.addTarget(self, action: #selector(minAmount), for: .touchUpInside)
        btn.setImage(UIImage(named: "yfs_buy_min_gray"), for: .disabled)
        return btn
    }()

    /// 增加按钮
    lazy var addButton: UIButton = {
        let btn = UIButton.with(imageName: "yfs_buy_add")
        btn.addTarget(self, action: #selector(addAmount), for: .touchUpInside)
        btn.setImage(UIImage(named: "yfs_buy_add_gray"), for: .disabled)
        return btn
    }()

    /// 成功视图
    fileprivate lazy var purchaseSuccessView: YiFanShangPurchaseSuccessView = YiFanShangPurchaseSuccessView()

    /// 卖完视图
    fileprivate lazy var amountEmptyView: YiFanShangAmountEmptyView = YiFanShangAmountEmptyView()

    /// 数量不足视图
//    fileprivate lazy var amountNotEnoughView: YiFanShangAmountNotEnoughView = {
//        let view = YiFanShangAmountNotEnoughView(remainCount: self.remainCount)
//        return view
//    }()

//    static var contentViewHeight: CGFloat = {
//        let font = UIFont.withBoldPixel(28).lineHeight
//        var height = 256+font*2
//
//        var bottomPadding: CGFloat = 0
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.keyWindow
//            bottomPadding = window?.safeAreaInsets.bottom ?? 0
//            height += bottomPadding
//        }
//        return height
//    }()

    /// 购买描述Label
    lazy var desLabel = UILabel.with(textColor: .black, boldFontSize: 28)

    /// 金额数组
    let amountArray = [5, 10, 20, 50]

    /// 金额按钮数组
    var moneyButtons: [UIButton] = []

    /// 剩余可购买数量
    var remainCount: Int = 0

    /// 购买数量
    var purchaseCount: Int = 1 {
        didSet {
            minButton.isEnabled = purchaseCount <= 1 ? false : true
            addButton.isEnabled = purchaseCount >= remainCount ? false : true
            if purchaseCount <= 1 {
                purchaseCount = 1
            } else if purchaseCount >= remainCount {
                purchaseCount = remainCount
            }
            textField.text = "\(purchaseCount)"

            let allStr = "购买 \(purchaseCount) 件，共 \(purchaseCount * price) 元气"
            let string = NSMutableAttributedString(string: allStr)
            string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.qu_red,
                                  NSAttributedString.Key.font: UIFont.withBoldPixel(28)],
                                 range: (allStr as NSString).range(of: "\(purchaseCount)"))
            string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.qu_red,
                                  NSAttributedString.Key.font: UIFont.withBoldPixel(28)],
                                 range: (allStr as NSString).range(of: "\(purchaseCount * price)"))
            desLabel.attributedText = string

            rechargeButton.isHidden = purchaseCount * price <= balance
        }
    }

    lazy var contentView = RoundedCornerView(corners: [.topLeft, .topRight], radius: 12, backgroundColor: .white)

    /// 充值按钮
    lazy var rechargeButton = UIButton.whiteTextCyanGreenBackgroundButton(title: "+ 立即充值", boldFontSize: 32)

    /// 输入值文本框
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .center
        tf.font = UIFont.withBoldPixel(32)
        tf.textColor = .qu_black
        tf.keyboardType = .numberPad
        tf.layer.borderColor = UIColor.qu_lightGray.cgColor
        tf.layer.borderWidth = 0.5
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return tf
    }()

    // MARK: - 初始化方法
    init(env: YiFanShangDetailEnvelope) {

        super.init(nibName: nil, bundle: nil)
        if let total = env.totalCount, let current = env.currentCount {
            remainCount = (Int(total) ?? 0) - (Int(current) ?? 0)
        }

        self.price = Int(env.price ?? "1") ?? 1
        self.purchaseViewModel = YiFanShangPurchaseViewModel(onePieceTaskRecordId: env.onePieceTaskRecordId ?? "",
                                                     count: purchaseCount)
        self.balance = Int(env.balance ?? "0") ?? 0
        setupView(env: env)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 键盘通知
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShowOrHide(notification: Notification) {
        let info = notification.userInfo
        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame = info?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let height = keyboardFrame.size.height

        if notification.name == UIResponder.keyboardWillShowNotification {
            self.contentView.layoutIfNeeded()
            UIView.animate(withDuration: duration) {
                self.contentView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(-height)
                }
            }
        } else {
            UIView.animate(withDuration: duration) {
                self.contentView.layoutIfNeeded()
                self.contentView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview()
                }
            }
        }
    }

    fileprivate func setupView(env: YiFanShangDetailEnvelope) {
        self.view.backgroundColor = .clear

        // 黑色透明遮罩
        let blackView = UIView.withBackgounrdColor(UIColor.qu_popBackgroundColor.alpha(0.6))
        blackView.tag = 440
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        gesture.delegate = self
        blackView.addGestureRecognizer(gesture)
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        contentView.tag = 441
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(272 + Constants.kScreenBottomInset)
        }

        // 我的元气
        let label = UILabel.with(textColor: .new_middleGray, fontSize: 24, defaultText: "我的元气")
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.height.equalTo(44)
        }

        let balanceLabel = UILabel.with(textColor: .new_middleGray, boldFontSize: 28, defaultText: env.balance)
        contentView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.left.equalTo(label.snp.right).offset(4)
        }

        // 当前剩余
        let remainCountLabel = UILabel.with(textColor: .black, boldFontSize: 28, defaultText: "\(remainCount)")
        contentView.addSubview(remainCountLabel)
        remainCountLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(label)
        }

        let remainLabel = UILabel.with(textColor: .new_middleGray, fontSize: 24, defaultText: "剩余可购买个数")
        contentView.addSubview(remainLabel)
        remainLabel.snp.makeConstraints { make in
            make.centerY.equalTo(remainCountLabel)
            make.right.equalTo(remainCountLabel.snp.left).offset(-8)
        }

        // 输入框
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(24)
            make.height.equalTo(40)
            make.width.equalTo(Constants.kScreenWidth - 134)
            make.centerX.equalToSuperview()
        }

        // - 按钮
        contentView.addSubview(minButton)
        minButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.centerY.equalTo(textField)
            make.right.equalTo(textField.snp.left)
        }

        // + 按钮
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.centerY.equalTo(textField)
            make.left.equalTo(textField.snp.right)
        }

        // 默认个数按钮
        let btnW: CGFloat = (Constants.kScreenWidth - 80) / 4
        for (index, money) in amountArray.enumerated() {
            let btn = YiFanShangPurchaseButton(amount: money)
            btn.addTarget(self, action: #selector(selectAmount(sender:)), for: .touchUpInside)
            btn.isUserInteractionEnabled = true
            contentView.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.top.equalTo(textField.snp.bottom).offset(16)
                make.height.equalTo(28)
                make.width.equalTo(btnW)
                make.left.equalToSuperview().offset(28 + (btnW + 8) * CGFloat(index))
            }
            moneyButtons.append(btn)
        }

        // 购买描述
        contentView.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(68)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }

        // 立即购买
        let purchaseButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "立即购买", boldFontSize: 32)
        purchaseButton.addTarget(self, action: #selector(purchase), for: .touchUpInside)
        contentView.addSubview(purchaseButton)
        purchaseButton.snp.makeConstraints { make in
            make.top.equalTo(desLabel.snp.bottom).offset(8)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(44)
        }

        // 充值
        rechargeButton.isHidden = true
        rechargeButton.addTarget(self, action: #selector(recharge), for: .touchUpInside)
        contentView.addSubview(rechargeButton)
        rechargeButton.snp.makeConstraints { make in
            make.size.equalTo(purchaseButton)
            make.center.equalTo(purchaseButton)
        }

        hideKeyboardWhenTappedOutside()

        purchaseCount = 1
    }

    // MARK: - 自定义方法
    @objc func recharge() {
        self.navigationController?.pushViewController(RechargeViewController(isOpenFromGameView: true), animated: true)
    }

    @objc func purchase() {
        MainViewController.isEggProductRefresh = true
        self.purchaseViewModel.purchaseSignal.onNext(purchaseCount)
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }

    /// 选中购买数量
    @objc func selectAmount(sender: UIButton) {
        let amount = sender.tag

        moneyButtons.forEach { btn in
            btn.isSelected = false
        }
        sender.isSelected = true
        purchaseCount = amount
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let purchaseCount = Int(textField.text ?? "1") {
            if purchaseCount > remainCount {
                self.textField.text = String.init(format: "%d", remainCount)
            }
            if purchaseCount == 0 {
                self.textField.text = "1"
            }
            self.purchaseCount = Int(textField.text ?? "1") ?? 1
        }
    }

    @objc func minAmount() {
        purchaseCount -= 1
    }

    @objc func addAmount() {
        purchaseCount += 1
    }

    @objc func normalDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func goToMembershipViewController() {
        self.dismiss(animated: true) {
            if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {
                if let top = root.selectedViewController?.topMostViewController as? NavigationController {
                    top.pushViewController(MembershipViewController(), animated: true)
                }
            }
        }
    }

    // MARK: - 数据绑定
    override func bindViewModels() {
        super.bindViewModels()

        self.purchaseViewModel.purchaseResult
            .subscribe(onNext: { env in
                self.handlePurchaseResult(env: env)
            })
            .disposed(by: disposeBag)

        self.purchaseViewModel.error
            .subscribe(onNext: { [weak self] env in
                HUD.showErrorEnvelope(env: env)
                self?.dismissVC()

                // 刷新状态
                if env.code == "4608" || env.code == "4703" {
                    if let callback = self?.refreshDataCallBack {
                        callback()
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    /// 处理购买结果
    func handlePurchaseResult(env: PurchaseResultEnvelope) {
        NotificationCenter.default.post(name: .yfsDetailPurchaseSeccess, object: nil)

        // 展示弹框
        UIView.animate(withDuration: 1.0, animations: {
            if let keyWindow = UIApplication.shared.keyWindow {
                self.purchaseSuccessView.show(in: keyWindow)
            }
        }, completion: { finished in
            self.purchaseSuccessView.remove()
            self.dismissVC()
        })

        // 回调刷新数据
        if let callback = self.refreshDataCallBack {
            callback()
        }
    }
}

extension YiFanShangPurchaseViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pointView = gestureRecognizer.location(in: view)
        if gestureRecognizer.isMember(of: UITapGestureRecognizer.self) && contentView.frame.contains(pointView) {
            return false
        }
        return true
    }
}

// 购买成功视图
private class YiFanShangPurchaseSuccessView: UIView {

    func remove() {
        self.removeFromSuperview()
    }

    func show(in view: UIView) {
        view.addSubview(self)
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kScreenHeight))

        self.backgroundColor = UIColor.black.alpha(0.6)
//        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        let contentViewHeight = 20+90+20+20+UIFont.withBoldPixel(28).lineHeight
        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(contentViewHeight)
            make.center.equalToSuperview()
        }

        let logo = UIImageView.with(imageName: "yfs_purchase_success")
        contentView.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.size.equalTo(90)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "购买成功")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logo.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//private class YiFanShangItemDetailView: UIView {
//
//    @objc func hide() {
//        self.removeFromSuperview()
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kScreenHeight))
//
//        self.backgroundColor = UIColor.black.alpha(0.6)
//        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
//        let contentViewHeight = 20+90+20+20+UIFont.withBoldPixel(28).lineHeight
//        let contentView = UIView.withBackgounrdColor(.white)
//        contentView.layer.cornerRadius = 8
//        contentView.layer.masksToBounds = true
//
//        addSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.width.equalTo(280)
//            make.height.equalTo(contentViewHeight)
//            make.center.equalToSuperview()
//        }
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

/// 卖完弹窗
private class YiFanShangAmountEmptyView: UIView {

    func remove() {
        self.removeFromSuperview()
    }

    func show(in view: UIView) {
        view.addSubview(self)
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kScreenHeight))

        self.backgroundColor = UIColor.black.alpha(0.6)
//        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo((176+96+24)/2)
            make.center.equalToSuperview()
        }

        let logo = UIImageView.with(imageName: "yfs_purchase_soldout")
        contentView.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 60))
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "本弹一番赏已经全部卖完啦")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logo.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// 数量不足弹窗
//private class YiFanShangAmountNotEnoughView: UIView {
//
//    func remove() {
//        self.removeFromSuperview()
//    }
//
//    func show(in view: UIView) {
//        view.addSubview(self)
//    }
//
//    var purchaseCallback: (() -> Void)?
//
//    let purchaseButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "立即购买", fontSize: 28)
//
//    init(remainCount: Int) {
//        super.init(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kScreenHeight))
//
//        self.backgroundColor = UIColor.black.alpha(0.6)
//
//        let contentView = UIView.withBackgounrdColor(.white)
//        contentView.layer.cornerRadius = 8
//        contentView.layer.masksToBounds = true
//        addSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.width.equalTo(280)
//            make.height.equalTo((176+96+24)/2)
//            make.center.equalToSuperview()
//        }
//
//        let titleLabel = UILabel()
//        titleLabel.textAlignment = .center
//        let totalStr = "本弹最多还可购买\(remainCount)件，是否继续购买？"
//        let string = NSMutableAttributedString(string: totalStr, attributes: [
//            NSAttributedString.Key.font: UIFont.withBoldPixel(28),
//            NSAttributedString.Key.foregroundColor: UIColor.qu_black
//            ])
//        let range = totalStr.range(of: "\(remainCount)")!
//        let nsRange = NSRange(range, in: totalStr)
//        string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.UIColorFromRGB(0xfd4152)], range: nsRange)
//        titleLabel.attributedText = string
//        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.height.equalTo(176/2)
//            make.top.left.right.equalToSuperview()
//        }
//
//        let reselectButton = UIButton.blackTextWhiteBackgroundYellowRoundedButton(title: "重新选择", fontSize: 28)
//        reselectButton.addTarget(self, action: #selector(reselect), for: .touchUpInside)
//        contentView.addSubview(reselectButton)
//        reselectButton.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(12)
//            make.height.equalTo(48)
//            make.width.equalTo(122)
//            make.top.equalTo(titleLabel.snp.bottom)
//        }
//
//        contentView.addSubview(purchaseButton)
//        purchaseButton.addTarget(self, action: #selector(purchase), for: .touchUpInside)
//        purchaseButton.snp.makeConstraints { make in
//            make.size.top.equalTo(reselectButton)
//            make.left.equalTo(reselectButton.snp.right).offset(12)
//        }
//    }
//
//    @objc func reselect() {
//        self.remove()
//    }
//
//    @objc func purchase() {
//        if let callback = purchaseCallback {
//            callback()
//        }
//        self.remove()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

private class YiFanShangPurchaseButton: UIButton {

    init(amount: Int) {
        super.init(frame: .zero)
        tag = amount
        setTitle("\(amount)", for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        setBackgroundColor(color: .new_backgroundColor, forUIControlState: .normal)
        setTitleColor(.new_middleGray, for: .normal)
        
        setBackgroundColor(color: .new_yellow, forUIControlState: .selected)
        setTitleColor(.black, for: .selected)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override var isSelected: Bool {
//        didSet {
//            layer.borderColor = isSelected ? UIColor.clear.cgColor : UIColor.qu_lightGray.cgColor
//        }
//    }
}
