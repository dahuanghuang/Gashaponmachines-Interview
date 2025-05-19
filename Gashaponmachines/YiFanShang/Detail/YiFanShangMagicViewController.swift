import UIKit

class YiFanShangMagicViewController: BaseViewController {

    let contentView = UIView.withBackgounrdColor(.clear)

    var magicPurchaseViewModel: YiFanShangMagicPurchaseViewModel!

    /// 刷新数据回调
    var refreshDataCallBack: (() -> Void)?

    /// 成功视图
    fileprivate lazy var purchaseSuccessView = YiFanShangMagicPurchaseSuccessView()

    /// 最多可选个数
    var limitCount: Int = 0

    /// 标题视图
    lazy var collectionView: UICollectionView = {
        let itemWH = (Constants.kScreenWidth - 48) / 4
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(YiFanShangMagicCell.self, forCellWithReuseIdentifier: YiFanShangMagicCellId)
        return cv
    }()

    lazy var cancelButton: UIButton = {
        let btn = UIButton.with(title: "取消", titleColor: UIColor(hex: "8a8a8a")!, boldFontSize: 32)
        btn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        btn.layer.cornerRadius = 4
        btn.backgroundColor = .qu_separatorLine
        return btn
    }()

    lazy var selectButton: UIButton = {
        let btn = UIButton.with(title: "立即选择", titleColor: .white, boldFontSize: 32)
        btn.addTarget(self, action: #selector(buyMagicTickes), for: .touchUpInside)
        btn.layer.cornerRadius = 4
        btn.backgroundColor = UIColor(hex: "fd4152")
        return btn
    }()

    var detailEnvelope: YiFanShangDetailEnvelope?

    /// 魔法券总个数
    var totalCount: Int = 0
    /// 拥有的券
    var ownMagicTickets = [String]()
    /// 选中的券
    var selectTickets = [String]()
    /// 选择标题
    let titleLb = UILabel.with(textColor: .qu_black, fontSize: 28)

    init(env: YiFanShangDetailEnvelope) {
        super.init(nibName: nil, bundle: nil)

        self.detailEnvelope = env

        self.magicPurchaseViewModel = YiFanShangMagicPurchaseViewModel(onePieceTaskRecordId: env.onePieceTaskRecordId ?? "")

        if let totalCount = env.totalCount, let count = Int(totalCount) {
            self.totalCount = count
        }

        if let tickets = env.magicDetail?.ownMagicTickets {
            self.ownMagicTickets = tickets
        }

        self.limitCount = totalCount - ownMagicTickets.count

        updateTitle()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        setupTitleView()
    }

    func updateTitle() {
        let attrM = NSMutableAttributedString(string: "本期剩余可选 ")
        attrM.append(NSAttributedString(string: "\(limitCount)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(hex: "fd4152")!]))
        attrM.append(NSAttributedString(string: " 已选 "))
        attrM.append(NSAttributedString(string: "\(selectTickets.count)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(hex: "fd4152")!]))
        self.titleLb.attributedText = attrM
    }

    func setupTitleView() {
        // 黑色透明遮罩
        let blackView = UIView.withBackgounrdColor(UIColor.qu_popBackgroundColor.alpha(0.6))
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        gesture.delegate = self
        blackView.addGestureRecognizer(gesture)
        view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(Constants.kScreenHeight*0.62)
        }
        
        let topBgImageView = UIImageView(image: UIImage(named: "yfs_magic_list_bg"))
        contentView.addSubview(topBgImageView)
        topBgImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        let logoIv = UIImageView(image: UIImage(named: "yfs_magic_list_logo"))
        topBgImageView.addSubview(logoIv)
        logoIv.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        titleLb.textAlignment = .left
        topBgImageView.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.left.equalTo(logoIv.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }

        let bottomView = UIView.withBackgounrdColor(.white)
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(Constants.kScreenBottomInset + 60)
        }

        let line = UIView.withBackgounrdColor(.qu_separatorLine)
        bottomView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        bottomView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(12)
            make.height.equalTo(44)
        }

        bottomView.addSubview(selectButton)
        selectButton.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(cancelButton)
            make.right.equalTo(-12)
            make.left.equalTo(cancelButton.snp.right).offset(12)
        }

        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(topBgImageView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
    }

    /// 开启魔法阵
    @objc func buyMagicTickes() {
        if selectTickets.isEmpty { return }
        magicPurchaseViewModel.purchaseSignal.onNext(selectTickets)
    }

    /// 取消
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - 数据绑定
    override func bindViewModels() {
        super.bindViewModels()

        self.magicPurchaseViewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)

        self.magicPurchaseViewModel.purchaseResult
            .subscribe(onNext: { [weak self] env in
                if env.code == "0" {
                    UIView.animate(withDuration: 1.0, animations: {
                        if let keyWindow = UIApplication.shared.keyWindow {
                            self?.purchaseSuccessView.show(in: keyWindow)
                        }
                    }, completion: { finished in
                        // 回调刷新数据
                        if let callback = self?.refreshDataCallBack {
                            callback()
                        }
                        self?.purchaseSuccessView.remove()
                        self?.dismissVC()
                    })
                } else {
                    HUD.showError(second: 1.0, text: env.msg, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension YiFanShangMagicViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YiFanShangMagicCellId, for: indexPath) as! YiFanShangMagicCell
        let number = "\(indexPath.row+1)"
        let canbuy = !ownMagicTickets.contains(number)
        let select = selectTickets.contains(number)
        cell.config(number: number, canBuy: canbuy, isSelect: select)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let number = "\(indexPath.row+1)"
        
        // 选中已经买过的票
        if ownMagicTickets.contains(number) { return }
        
        if selectTickets.contains(number) {
            selectTickets = selectTickets.filter { $0 != number }
        } else {
            if selectTickets.count == limitCount {
                HUD.showError(second: 1.0, text: "最多可选\(limitCount)个", completion: nil)
                return
            }
            selectTickets.append(number)
        }
        updateTitle()
        collectionView.reloadItems(at: [indexPath])
    }
}

extension YiFanShangMagicViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pointView = gestureRecognizer.location(in: view)
        if gestureRecognizer.isMember(of: UITapGestureRecognizer.self) && contentView.frame.contains(pointView) {
            return false
        }
        return true
    }
}

// 购买成功视图
private class YiFanShangMagicPurchaseSuccessView: UIView {

    func remove() {
        self.removeFromSuperview()
    }

    func show(in view: UIView) {
        view.addSubview(self)
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kScreenHeight))

        self.backgroundColor = UIColor.black.alpha(0.6)
        let contentViewHeight = 20+90+20+20+UIFont.withBoldPixel(28).lineHeight
        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(contentViewHeight)
            make.center.equalToSuperview()
        }

        let logo = UIImageView.with(imageName: "yfs_magic_purchase_success")
        contentView.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.size.equalTo(90)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "开启成功")
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
