class YiFanShangDetailImageViewController: BaseViewController {

    private var items: [AwardInfo] = []

    init(items: [AwardInfo]) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.contentSize = CGSize(width: Constants.kScreenWidth * CGFloat(items.count), height: Constants.kScreenHeight)
        scrollView.isPagingEnabled = true
        return scrollView
    }()

    @objc func removeVC() {
        self.dismiss(animated: true, completion: nil)
    }

    var contentViewsFrames: [CGRect] = []

    static let contentViewHeight: CGFloat = 311+64+20
    static let contentViewWidth: CGFloat  = 311

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.alpha(0.6)

        let ges = UITapGestureRecognizer(target: self, action: #selector(removeVC))
        ges.delegate = self
        self.view.addGestureRecognizer(ges)

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for (idx, item) in items.enumerated() {

            let contentView = UIView.withBackgounrdColor(.white)
            contentView.layer.cornerRadius = 8
            contentView.layer.masksToBounds = true
            scrollView.addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(Constants.kScreenWidth / 2 - 311 / 2 + CGFloat(idx) * Constants.kScreenWidth)
                make.width.equalTo(YiFanShangDetailImageViewController.contentViewWidth)
                make.height.equalTo(YiFanShangDetailImageViewController.contentViewHeight)
            }

            let iv = UIImageView()
            iv.gas_setImageWithURL(item.image, targetSize: 311)
            contentView.addSubview(iv)
            iv.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.size.equalTo(311)
            }

            let icon = UIImageView.with(imageName: "yfs_icon_\(idx)")
            iv.addSubview(icon)
            icon.snp.makeConstraints { make in
                make.top.left.equalToSuperview().offset(4)
                make.size.equalTo(CGSize(width: 80, height: 36))
            }

            let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: item.title)
            titleLabel.numberOfLines = 2
            titleLabel.textAlignment = .center
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(iv.snp.bottom)
                make.left.right.equalToSuperview()
            }

            let desLabel = UILabel.with(textColor: UIColor.qu_orange, boldFontSize: 24, defaultText: "* 购买定赏可获赠升级券并有机会升级成该商品 *")
            desLabel.textAlignment = .center
            desLabel.backgroundColor = UIColor.UIColorFromRGB(0xfff5c6)
            contentView.addSubview(desLabel)
            desLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(32)
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
            }

            if idx == 0 {
                let rightButton = UIButton.with(imageName: "yfs_item_right")
                rightButton.addTarget(self, action: #selector(goRight), for: .touchUpInside)
                scrollView.addSubview(rightButton)
                rightButton.snp.makeConstraints { make in
                    make.size.equalTo(48)
                    make.right.equalTo(contentView).offset(24)
                    make.centerY.equalTo(contentView)
                }
            } else if idx == items.count - 1 {
                let leftButton = UIButton.with(imageName: "yfs_item_left")
                leftButton.addTarget(self, action: #selector(goLeft), for: .touchUpInside)
                scrollView.addSubview(leftButton)
                leftButton.snp.makeConstraints { make in
                    make.size.equalTo(48)
                    make.left.equalTo(contentView).offset(-24)
                    make.centerY.equalTo(contentView)
                }
            } else {
                let rightButton = UIButton.with(imageName: "yfs_item_right")
                rightButton.addTarget(self, action: #selector(goRight), for: .touchUpInside)
                scrollView.addSubview(rightButton)
                rightButton.snp.makeConstraints { make in
                    make.size.equalTo(48)
                    make.right.equalTo(contentView).offset(24)
                    make.centerY.equalTo(contentView)
                }

                let leftButton = UIButton.with(imageName: "yfs_item_left")
                leftButton.addTarget(self, action: #selector(goLeft), for: .touchUpInside)
                scrollView.addSubview(leftButton)
                leftButton.snp.makeConstraints { make in
                    make.size.equalTo(48)
                    make.left.equalTo(contentView).offset(-24)
                    make.centerY.equalTo(contentView)
                }
            }
        }
    }

    @objc func goLeft() {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x - Constants.kScreenWidth, y: scrollView.contentOffset.y), animated: true)
    }

    @objc func goRight() {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x + Constants.kScreenWidth, y: scrollView.contentOffset.y), animated: true)
    }
}

extension YiFanShangDetailImageViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pointView = gestureRecognizer.location(in: view)
        let contentViewRect = CGRect(x: Constants.kScreenWidth / 2 - YiFanShangDetailImageViewController.contentViewWidth / 2,
                                     y: Constants.kScreenHeight / 2 - YiFanShangDetailImageViewController.contentViewHeight / 2,
                                     width: YiFanShangDetailImageViewController.contentViewWidth,
                                     height: YiFanShangDetailImageViewController.contentViewHeight)
        if gestureRecognizer.isMember(of: UITapGestureRecognizer.self) && contentViewRect.contains(pointView) {
            return false
        }
        return true
    }
}
