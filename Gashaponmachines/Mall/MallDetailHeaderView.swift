
import RxSwift
import RxCocoa


extension Reactive where Base: MallDetailHeaderView {
    var backButtonTap: ControlEvent<Void> {
        return self.base.backButton.rx.controlEvent(.touchUpInside)
    }
}

class MallDetailHeaderView: UIView {
    /// 商品图
    let productIv = UIImageView()
    /// 白色圆角背景
    lazy var whiteContainer: UIView = {
        let view = UIView.withBackgounrdColor(.white)
        view.layer.cornerRadius = 12
        return view
    }()
    /// 元气值图片
    let lightValueIv = UIImageView(image: UIImage(named: "mall_egg"))
    /// 元气值
    lazy var lightValueLabel: UILabel = {
        let lb = UILabel.numberFont(size: 28)
        lb.textAlignment = .left
        return lb
    }()
    /// 原价值
    lazy var originLabel: UILabel = {
        let lb = UILabel.numberFont(size: 20)
        lb.textColor = .qu_lightGray
        lb.isHidden = true
        return lb
    }()
    /// 商品名
    lazy var titleLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, boldFontSize: 32)
        lb.preferredMaxLayoutWidth = Constants.kScreenWidth - 48
        lb.numberOfLines = 0
        lb.textAlignment = .left
        return lb
    }()
    /// 商品详情背景
    let detailContainer = UIView.withBackgounrdColor(.white)
    /// 商品详情
    let detailLb = UILabel.with(textColor: .black, boldFontSize: 24, defaultText: "商品详情")
    /// 返回按钮
    lazy var backButton: UIButton = {
        let btn =  UIButton.with(imageName: "nav_back_black")
        btn.layer.cornerRadius = 14
        btn.backgroundColor = .new_lightGray.alpha(0.4)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .new_backgroundColor
        
        self.addSubview(productIv)
        productIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kScreenWidth)
        }

        self.addSubview(whiteContainer)
        whiteContainer.snp.makeConstraints { make in
            make.top.equalTo(productIv.snp.bottom).offset(12)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        
        whiteContainer.addSubview(lightValueIv)
        lightValueIv.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(8)
            make.size.equalTo(16)
        }
        
        whiteContainer.addSubview(lightValueLabel)
        lightValueLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(lightValueIv.snp.right).offset(2)
            make.height.equalTo(28)
        }
        
        whiteContainer.addSubview(originLabel)
        originLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lightValueLabel.snp.right).offset(4)
            make.centerY.equalTo(lightValueLabel)
        }
        
        whiteContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(lightValueIv)
            make.top.equalTo(lightValueIv.snp.bottom).offset(12)
            make.right.equalTo(-8)
            make.bottom.equalToSuperview().offset(-12)
        }

        self.addSubview(detailContainer)
        detailContainer.snp.makeConstraints { make in
            make.top.equalTo(whiteContainer.snp.bottom).offset(12)
            make.left.right.equalTo(whiteContainer)
            make.height.equalTo(34)
            make.bottom.equalToSuperview()
        }
        
        detailContainer.addSubview(detailLb)
        detailLb.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.top.equalTo(8)
            make.size.equalTo(28)
        }
    }
    
    func configureWith(product: MallProduct) {
        self.productIv.qu_setImageWithURL(URL(string: product.image)!)
        self.lightValueLabel.text = product.worth
        self.titleLabel.text = product.title
        
        if let isOnDiscount = product.isOnDiscount, isOnDiscount == "1" {
            if let originWorth = product.originalWorth {
                let attrStr = NSAttributedString(string: originWorth, attributes: [NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)])
                originLabel.attributedText = attrStr
                originLabel.isHidden = false
            }
            lightValueLabel.textColor = .new_discountColor
        }else {
            originLabel.isHidden = true
            lightValueLabel.textColor = .qu_black
        }

//        if let isOnDiscount = product.isOnDiscount, isOnDiscount == "1" {
//            self.originPrizeLabel.addStrikeThroughLine(with: product.originalWorth)
//            self.valueLabel.textColor = .qu_red6
//        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        detailContainer.roundCorners([.topLeft, .topRight], radius: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
