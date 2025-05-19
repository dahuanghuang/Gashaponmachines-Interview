//import UIKit
//
//class YiFanShangDetailImageView: UIView {
//    private var items: [AwardInfo] = []
//
//    private var currentIndex: Int = 0
//
//    init(items: [AwardInfo], index: Int) {
//        super.init(frame: .zero)
//        self.items = items
//        self.currentIndex = index
//        setupUI()
//    }
//
//    lazy var scrollView: UIScrollView = {
//        let view = UIScrollView()
//        view.layer.cornerRadius = 8
//        view.layer.masksToBounds = true
//        view.delegate = self
//        view.backgroundColor = .clear
//        view.contentSize = CGSize(width: 311 * CGFloat(items.count), height: 431)
//        view.isPagingEnabled = true
//        view.bounces = false
//        return view
//    }()
//
//    static let contentViewHeight: CGFloat = 311+64+20
//    static let contentViewWidth: CGFloat  = 311
//
//    var leftButton = UIButton.with(imageName: "yfs_item_left")
//
//    var rightButton = UIButton.with(imageName: "yfs_item_right")
//
//    /// 商品详情跳转
//    var routerCallback: ((String) -> Void)?
//
//    func setupUI() {
//        self.backgroundColor = UIColor.black.alpha(0.6)
//
//        let ges = UITapGestureRecognizer(target: self, action: #selector(remove))
//        ges.delegate = self
//        self.addGestureRecognizer(ges)
//
//        addSubview(scrollView)
//        scrollView.bounds = CGRect(x: 0, y: 0, width: 311, height: 431)
//        scrollView.center = CGPoint(x: Constants.kScreenWidth/2, y: Constants.kScreenHeight/2)
//
//        for (idx, item) in items.enumerated() {
//            setupContentView(idx: idx, item: item)
//        }
//
//        setupButtons()
//
//        setupScroll()
//    }
//
//    func setupScroll() {
//        let endIndex = items.count - 1
//        if currentIndex < 0 && currentIndex > endIndex {
//            return
//        }
//
//        if currentIndex == endIndex {
//            self.rightButton.isHidden = true
//            self.leftButton.isHidden = false
//        } else if currentIndex > 0 && currentIndex < endIndex {
//            self.rightButton.isHidden = false
//            self.leftButton.isHidden = false
//        }
//
//        self.scrollView.setContentOffset(CGPoint(x: self.scrollView.width * CGFloat(self.currentIndex), y: self.scrollView.contentOffset.y), animated: false)
//    }
//
//    func setupContentView(idx: Int, item: AwardInfo) {
//        let contentView = UIView.withBackgounrdColor(.white)
////        contentView.layer.cornerRadius = 8
////        contentView.layer.masksToBounds = true
//        scrollView.addSubview(contentView)
//        contentView.frame = CGRect(x: CGFloat(idx) * scrollView.width, y: 0, width: scrollView.width, height: scrollView.height)
//
//        // 商品图片
//        let iv = UIImageView()
//        iv.isUserInteractionEnabled = true
//        let ges = UITapGestureRecognizer(target: self, action: #selector(jumpToMallProduct))
//        iv.addGestureRecognizer(ges)
//        iv.gas_setImageWithURL(item.productImage, targetSize: 311)
//        contentView.addSubview(iv)
//        iv.snp.makeConstraints { make in
//            make.top.left.right.equalToSuperview()
//            //                make.size.equalTo(311)
//            make.height.equalTo(iv.snp.width)
//        }
//
//        // A赏图标
//        let icon = UIImageView()
//        icon.gas_setImageWithURL(item.eggBackgroundImage, targetSize: CGSize(width: 80, height: 36))
//        iv.addSubview(icon)
//        icon.snp.makeConstraints { make in
//            make.top.left.equalToSuperview().offset(4)
//            make.size.equalTo(CGSize(width: 80, height: 36))
//        }
//
//        // 提示
////        let desLabel = UILabel.with(textColor: UIColor.qu_orange, boldFontSize: 24, defaultText: "* 购买定赏可获赠升级券并有机会升级成该商品 *")
//        let desLabel = UILabel.with(textColor: UIColor.qu_orange, boldFontSize: 24, defaultText: item.eggDescription)
//        desLabel.textAlignment = .center
//        desLabel.backgroundColor = UIColor.UIColorFromRGB(0xfff5c6)
//        contentView.addSubview(desLabel)
//        desLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.height.equalTo(32)
//            make.bottom.equalToSuperview()
//            make.left.right.equalToSuperview()
//        }
//
//        // 奖品名称
//        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: item.productTitle)
//        titleLabel.numberOfLines = 2
//        titleLabel.textAlignment = .center
//        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(iv.snp.bottom)
//            make.left.equalTo(12)
//            make.right.equalTo(-12)
//            make.bottom.equalTo(desLabel.snp.top)
//        }
//    }
//
//    func setupButtons() {
//        leftButton.addTarget(self, action: #selector(goLeft), for: .touchUpInside)
//        leftButton.isHidden = true
//        addSubview(leftButton)
//        leftButton.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.width.height.equalTo(48)
//            make.centerX.equalTo(scrollView.left)
//        }
//
//        rightButton.addTarget(self, action: #selector(goRight), for: .touchUpInside)
//        addSubview(rightButton)
//        rightButton.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.width.height.equalTo(48)
//            make.centerX.equalTo(scrollView.right)
//        }
//    }
//
//    @objc func goLeft() {
//        if currentIndex <= 0 {
//            return
//        }
//
//        if currentIndex == 1 {
//            self.leftButton.isHidden = true
//        }
//
//        self.rightButton.isHidden = false
//        currentIndex -= 1
//
//        UIView.animate(withDuration: 0.5, animations: {
//            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.width * CGFloat(self.currentIndex), y: self.scrollView.contentOffset.y), animated: false)
//        })
//    }
//
//    @objc func goRight() {
//        let endIndex = items.count - 1
//
//        // 不合法情况
//        if currentIndex >= endIndex {
//            return
//        }
//
//        // 下一个是最后一个时
//        if currentIndex == endIndex - 1 {
//            self.rightButton.isHidden = true
//        }
//
//        self.leftButton.isHidden = false
//        currentIndex += 1
//
//        UIView.animate(withDuration: 0.5, animations: {
//            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.width * CGFloat(self.currentIndex), y: self.scrollView.contentOffset.y), animated: false)
//        })
//    }
//
//    @objc func jumpToMallProduct() {
//        if let callback = self.routerCallback {
//            let awardInfo = self.items[currentIndex]
//            if let link = awardInfo.action {
//                callback(link)
//            }
//        }
//        self.remove()
//    }
//
//    @objc func remove() {
//        self.removeFromSuperview()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//extension YiFanShangDetailImageView: UIScrollViewDelegate {
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        currentIndex = Int(scrollView.contentOffset.x / scrollView.width)
//
//        if currentIndex == 0 {
//            leftButton.isHidden = true
//        } else {
//            rightButton.isHidden = false
//        }
//        if currentIndex == items.count - 1 {
//            rightButton.isHidden = true
//        } else {
//            leftButton.isHidden = false
//        }
//    }
//}
//
//extension YiFanShangDetailImageView: UIGestureRecognizerDelegate {
//
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let pointView = gestureRecognizer.location(in: self)
//        let contentViewRect = CGRect(x: Constants.kScreenWidth / 2 - YiFanShangDetailImageView.contentViewWidth / 2,
//                                     y: Constants.kScreenHeight / 2 - YiFanShangDetailImageView.contentViewHeight / 2,
//                                     width: YiFanShangDetailImageView.contentViewWidth,
//                                     height: YiFanShangDetailImageView.contentViewHeight)
//        if gestureRecognizer.isMember(of: UITapGestureRecognizer.self) && contentViewRect.contains(pointView) {
//            return false
//        }
//        return true
//    }
//}
