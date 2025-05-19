import SnapKit

class MallContentCollectionViewCell: UICollectionViewCell {

    /// 商品图片
    let productIv = UIImageView()
    let machineIcon = UIImageView()
    /// 商品名
    lazy var titleLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, fontSize: 24)
        lb.numberOfLines = 2
        lb.textAlignment = .left
        return lb
    }()
    /// 元气值图片
    let lightValueIv = UIImageView(image: UIImage(named: "mall_egg"))
    /// 元气值
    let lightValueLabel = UILabel.numberFont(size: 16)
    /// 原价值
    lazy var originLabel: UILabel = {
        let lb = UILabel.numberFont(size: 10)
        lb.textColor = .qu_lightGray
        lb.isHidden = true
        return lb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    func setupView() {
        self.backgroundColor = .white

        productIv.layer.cornerRadius = 8
        productIv.layer.masksToBounds = true
        contentView.addSubview(productIv)
        productIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(productIv.snp.width)
        }

        productIv.addSubview(machineIcon)
        machineIcon.snp.makeConstraints { make in
            make.right.equalTo(productIv).offset(-4)
            make.top.equalTo(productIv).offset(4)
        }

        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(productIv.snp.bottom).offset(6)
            make.left.equalTo(productIv).offset(4)
            make.right.equalTo(productIv).offset(-4)
        }
        
        contentView.addSubview(lightValueIv)
        lightValueIv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(12)
        }

        contentView.addSubview(lightValueLabel)
        lightValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lightValueIv.snp.right).offset(2)
            make.centerY.equalTo(lightValueIv)
        }

        contentView.addSubview(originLabel)
        originLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lightValueLabel.snp.right).offset(2)
            make.centerY.equalTo(lightValueLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(product: MallProduct) {

        clean()

        productIv.gas_setImageWithURL(product.image)
        titleLabel.text = product.title
        lightValueLabel.text = product.worth
        
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
    }

    func clean() {
        productIv.image = nil
        titleLabel.text = ""
        lightValueLabel.text = ""
        originLabel.text = ""
    }
}
