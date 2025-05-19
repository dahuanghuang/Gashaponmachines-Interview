import UIKit

/// 搜索商城商品cell
let SearchProductMallCellId = "SearchProductMallCellId"

class SearchProductMallCell: UICollectionViewCell {
    /// 商品图片
    let productIv = UIImageView()
    /// 限时特价
    let discountIv = UIImageView(image: UIImage(named: "mall_onsale"))
    /// 商品名
    lazy var titleLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, fontSize: 26)
        lb.numberOfLines = 2
        lb.textAlignment = .left
        return lb
    }()
    /// 蛋壳值图片
    let lightValueIv = UIImageView(image: UIImage(named: "mall_egg"))
    /// 蛋壳值
    let lightValueLabel = UILabel.numberFont(size: 20)
    /// 原价值
    lazy var originLabel: UILabel = {
        let lb = UILabel.numberFont(size: 12)
        lb.textColor = .qu_lightGray
        lb.isHidden = true
        return lb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(productIv)
        productIv.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(productIv.snp.width)
        }
        
        productIv.addSubview(discountIv)
        discountIv.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(productIv.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }

        contentView.addSubview(lightValueIv)
        lightValueIv.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-14)
        }

        contentView.addSubview(lightValueLabel)
        lightValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lightValueIv.snp.right).offset(2)
            make.centerY.equalTo(lightValueIv)
        }

        contentView.addSubview(originLabel)
        originLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lightValueLabel.snp.right).offset(4)
            make.centerY.equalTo(lightValueLabel)
        }
    }

    func config(product: SearchMallProduct) {

        clean()

        productIv.gas_setImageWithURL(product.image)
        titleLabel.text = product.title
        lightValueLabel.text = product.worth

        if let originPrice = product.originalWorth {
            let attrStr = NSAttributedString(string: originPrice, attributes: [NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)])
            originLabel.attributedText = attrStr
            originLabel.isHidden = false
            discountIv.isHidden = false
            lightValueLabel.textColor = .new_discountColor
            lightValueIv.image = UIImage(named: "mall_onsale_egg")
        } else {
            originLabel.isHidden = true
            discountIv.isHidden = true
            lightValueLabel.textColor = .qu_black
            lightValueIv.image = UIImage(named: "mall_egg")
        }
    }

    func clean() {
        productIv.image = nil
        titleLabel.text = ""
        lightValueLabel.text = ""
    }
}
