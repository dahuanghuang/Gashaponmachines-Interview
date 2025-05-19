import RxCocoa
import RxSwift

class AccquiredItemHeaderView: UIView {
    var eggproduct: EggProduct? {
        didSet {
            if let product = eggproduct, let tips = product.tips {
                self.remainLabel.text = tips
                self.titleLabel.text = product.title
                self.timeLabel.text = product.expireDate

                if product.isLocked == "0" {
//                    let attrM = NSMutableAttributedString(string: product.worth ?? "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 11)])
//                    attrM.append(NSAttributedString(string: "蛋壳"))
//                    self.valueLabel.attributedText = attrM
                    self.valueLabel.text = "\(product.worth ?? "") 蛋壳"
                } else {
                    self.valueLabel.text = "暂锁定"
                }

                self.icon.qu_setImageWithURL(URL(string: product.image)!)

                if let needWarn = product.needWarning, needWarn {
                    self.timeView.backgroundColor = .qu_red
                } else {
                    self.timeView.backgroundColor = .qu_cyanGreen
                }

            } else {
                self.container.isHidden = true
            }
        }
    }

    // 背景
    lazy var container = UIView.withBackgounrdColor(.white)
    // 图片
    lazy var icon = UIImageView()
    // 价值
    lazy var valueLabel = UILabel.with(textColor: .qu_black, boldFontSize: 20)
    // 有效时间背景
    lazy var timeView = UIView()
    // 有效时间logo
    let clock = UIImageView(image: UIImage(named: "dancao_clock"))
    // 有效时间提示
    lazy var remainLabel = UILabel.with(textColor: .white, fontSize: 20)
    // 时间
    lazy var timeLabel = UILabel.with(textColor: UIColor(hex: "D29F26")!, fontSize: 20)
    // 标题
    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    /// 删除颜色信息
    func getNewTips(tip: String) -> NSAttributedString {
        var tips = tip
        for _ in 0...1 {
            if let startIndex = tips.firstIndex(of: "<"),
                let endIndex = tips.firstIndex(of: ">") {
                let colorStr = String(tips[startIndex...endIndex])
                let range = tips.range(of: colorStr)!
                tips.removeSubrange(range)
            }
        }

        return NSAttributedString.init(string: tips, attributes: [.foregroundColor: UIColor.white, .font: UIFont.withBoldPixel(20)])
    }
    
    let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        
        // 底部渐变色
        gradientLayer.colors = [UIColor(hex: "FF902B")!.cgColor, UIColor(hex: "FF902B")!.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        self.layer.addSublayer(gradientLayer)
        
        // 底部背景图片
        let bgIv = UIImageView(image: UIImage(named: "dancao_header_bg"))
        self.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 背景
        container.layer.cornerRadius = 12
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.right.bottom.equalTo(-12)
        }

        // 商品图
        icon.layer.cornerRadius = 8
        icon.layer.masksToBounds = true
        container.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.width.equalTo(icon.snp.height)
        }

        // 价值
        let valueView = UIView.withBackgounrdColor(.qu_yellow)
        valueView.layer.cornerRadius = 4
        valueView.layer.masksToBounds = true
        container.addSubview(valueView)

        valueView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalTo(8)
            make.right.equalTo(-8)
        }

        valueView.snp.makeConstraints { (make) in
            make.bottom.equalTo(icon)
            make.left.equalTo(icon.snp.right).offset(8)
            make.height.equalTo(18)
        }

        // 兑换时间视图
        timeView.layer.cornerRadius = 4
        timeView.layer.masksToBounds = true
        container.addSubview(timeView)

        timeView.addSubview(clock)
        clock.snp.makeConstraints { make in
            make.left.equalTo(timeView).offset(8)
            make.centerY.equalTo(timeView)
        }

        timeView.addSubview(remainLabel)
        remainLabel.numberOfLines = 1
        remainLabel.snp.makeConstraints { make in
            make.left.equalTo(clock.snp.right).offset(4)
            make.centerY.equalTo(timeView)
        }

        timeView.snp.makeConstraints { make in
            make.top.bottom.equalTo(valueView)
            make.left.equalTo(valueView.snp.right).offset(4)
            make.right.equalTo(remainLabel).offset(8)
        }

        // 时间
        container.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(valueView)
            make.bottom.equalTo(valueView.snp.top).offset(-14)
            make.height.equalTo(11)
        }

        // 商品标题
        titleLabel.numberOfLines = 2
        container.addSubview(titleLabel)
        titleLabel.textAlignment = .left
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(icon)
            make.left.equalTo(icon.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
        }
        
        let topLine = UIImageView(image: UIImage(named: "dancao_header_top_line"))
        container.addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalTo(icon)
        }
        
        let bottomLine = UIImageView(image: UIImage(named: "dancao_header_bottom_line"))
        container.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalTo(icon)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = self.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
