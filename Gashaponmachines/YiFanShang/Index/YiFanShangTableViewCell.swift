class YiFanShangTableViewCell: BaseTableViewCell {

    /// 结束视图高度
    static let EndViewH: CGFloat = 72

    static let ImageViewWidth = (Constants.kScreenWidth - 40)
    static let ImageViewHeight = 0.48 * ImageViewWidth

    /// 商品图
    lazy var productIv: UIImageView = {
        var iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    /// 左上角状态
    lazy var statusIv: UIImageView = UIImageView()
    /// 左上角价格
    lazy var priceLabel: UILabel = {
        let lb = UILabel.numberFont(size: 16)
        lb.textColor = .white
        return lb
    }()
    let yuanqiLb = UILabel.with(textColor: .white, boldFontSize: 24, defaultText: "元气")
    /// 商品名
    lazy var titleLabel: UILabel =  UILabel.with(textColor: .white, boldFontSize: 26)
    /// 进度值
    lazy var progressLabel: UILabel = UILabel.with(textColor: .white, fontSize: 24)
    /// 进度条
    lazy var progressView: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.progressTintColor = UIColor.qu_yellow
        progressBar.trackTintColor = UIColor.black.alpha(0.8)
        return progressBar
    }()

    /// 结束视图
    lazy var endView: UIView = UIView.withBackgounrdColor(.clear)

    /// 左上角价格视图
//    let topLeftView = RoundedCornerView(corners: [.topLeft, .bottomRight], radius: 6, backgroundColor: .red.alpha(0.8))
    let topLeftView = UIView.withBackgounrdColor(.clear)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear

        // 结束视图
        contentView.addSubview(endView)
        endView.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }

        let endIv = UIImageView(image: UIImage(named: "yfs_list_end_iv"))
        endView.addSubview(endIv)
        endIv.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-20)
        }

        // cell白色背景
        contentView.addSubview(productIv)
        productIv.snp.makeConstraints { make in
            make.top.equalTo(endView.snp.bottom)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview()
        }

        // 左上角黑色视图
        productIv.addSubview(topLeftView)
//        topLeftView.snp.makeConstraints { make in
//            make.top.left.equalTo(8)
//            make.left.equalTo(8)
//            make.height.equalTo(24)
//        }
        
        topLeftView.addSubview(statusIv)
        statusIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(4)
            make.size.equalTo(16)
        }

        topLeftView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(1)
            make.left.equalTo(statusIv.snp.right).offset(4)
        }
        
        topLeftView.addSubview(yuanqiLb)
        yuanqiLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(priceLabel.snp.right).offset(1)
//            make.right.equalTo(-4)
        }
        
        let cornerBgIv = UIImageView(image: UIImage(named: "yfs_topleft_bg"))
        topLeftView.insertSubview(cornerBgIv, belowSubview: statusIv)
        cornerBgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 进度背景
        let bottomContainer = UIView.withBackgounrdColor(.black.alpha(0.6))
        productIv.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(25)
        }

        progressLabel.textAlignment = .right
        bottomContainer.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
//            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(60).priority(.high)
        }

        bottomContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.right.lessThanOrEqualTo(progressLabel.snp.left).offset(-8)
        }

        productIv.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.equalTo(bottomContainer)
            make.height.equalTo(1)
            make.bottom.equalTo(bottomContainer.snp.top)
        }
    }

    func configureWith(item: YiFanShangItem, isEnd: Bool) {

        self.cleanData()
        
        priceLabel.text = item.price

        titleLabel.text = item.title

        productIv.gas_setImageWithURL(item.image)

        if item.status != nil, item.status == YiFanShangItemStatus.running || item.status == YiFanShangItemStatus.waiting {
            progressLabel.textColor = UIColor.UIColorFromRGB(0xffcc3e)
        } else {
            progressLabel.textColor = .white
        }
        progressLabel.text = item.progressTip

        if let progress = item.progress {
            progressView.progress = Float(progress) ?? 0
        }

        statusIv.image = item.status?.yfsIcon

        // 展示结束分割线
        if isEnd {
            endView.isHidden = false
            endView.snp.updateConstraints { (make) in
                make.height.equalTo(YiFanShangTableViewCell.EndViewH)
            }
        } else {
            endView.isHidden = true
            endView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        }
        
        // 重新布局左上角视图
        let w = self.getTopLeftViewWidth()
        topLeftView.snp.remakeConstraints { make in
            make.top.left.equalTo(8)
            make.height.equalTo(24)
            make.width.equalTo(w)
        }
    }
    
    /// 获取左上角视图的宽度
    func getTopLeftViewWidth() -> CGFloat {
        var width = 29.0
        if let p = priceLabel.text {
            width += p.sizeOfString(usingFont: UIFont(name: "BebasNeue-Regular", size: 16)!).width
        }
        if let y = yuanqiLb.text {
            width += y.sizeOfString(usingFont: UIFont.boldSystemFont(ofSize: 12)).width
        }
        return width
    }
    
    func cleanData() {
        priceLabel.text = ""
        titleLabel.text = ""
        productIv.image = nil
        progressLabel.text = ""
        statusIv.image = nil
        topLeftView.snp.remakeConstraints { make in
            make.top.left.equalTo(8)
            make.height.equalTo(24)
            make.width.equalTo(0)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
