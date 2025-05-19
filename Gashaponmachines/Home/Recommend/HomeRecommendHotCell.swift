import UIKit

let HomeRecommendHotCellId = "HomeRecommendHotCellId"

class HomeRecommendHotCell: UICollectionViewCell {

    // cell宽度
    static let cellW = ((Constants.kScreenWidth - 64) / 3)
    // cell高度
    static let cellH = HomeRecommendHotCell.cellW + 72

    /// 商品图片
    let productIv = UIImageView()
    /// 机台状态图片
    let machineStatusIv = UIImageView()
    /// 机台类型图片
    let machineTypeIv = UIImageView()
    /// 商品名
    lazy var titleLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, boldFontSize: 24)
        lb.textAlignment = .left
        lb.numberOfLines = 2
        return lb
    }()
    /// 元气值图片
    let lightValueIv = UIImageView(image: UIImage(named: "home_light_value"))
    /// 元气值
    let lightValueLabel = UILabel.numberFont(size: 20)
    /// 原价值
    lazy var originLabel: UILabel = {
        let lb = UILabel.numberFont(size: 12)
        lb.textColor = .qu_lightGray
        lb.isHidden = true
        return lb
    }()
    /// 领养人头像
    lazy var ownerIv: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4

        contentView.addSubview(productIv)
        productIv.addSubview(machineStatusIv)
        productIv.addSubview(machineTypeIv)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lightValueIv)
        contentView.addSubview(lightValueLabel)
        contentView.addSubview(originLabel)
        contentView.addSubview(ownerIv)
    }

    func config(machine: HomeMachine) {

        clean()

        productIv.gas_setImageWithURL(machine.image)
        machineTypeIv.image = UIImage(named: machine.type.image)
        machineStatusIv.image = UIImage(named: machine.status.small_image)
        titleLabel.text = machine.title
        lightValueLabel.text = machine.priceStr

        if let originPrice = machine.originalPrice {
            let attrStr = NSAttributedString(string: originPrice, attributes: [NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)])
            originLabel.attributedText = attrStr
            originLabel.isHidden = false
            lightValueLabel.textColor = .new_discountColor
        } else {
            originLabel.isHidden = true
            lightValueLabel.textColor = .qu_black
        }

        if let owner = machine.owner {
            ownerIv.isHidden = false
            ownerIv.gas_setImageWithURL(owner.avatar)
        } else {
            ownerIv.isHidden = true
        }
    }

    func clean() {
        productIv.image = nil
        machineTypeIv.image = nil
        machineStatusIv.image = nil
        titleLabel.text = ""
        lightValueLabel.text = ""
        ownerIv.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        productIv.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(productIv.snp.width)
        }
        
        machineStatusIv.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
        }
        
        machineTypeIv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
            make.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(productIv.snp.bottom).offset(6)
            make.left.equalTo(4)
            make.right.equalTo(-4)
        }
        
        lightValueIv.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(-10)
            make.size.equalTo(12)
        }
        
        lightValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lightValueIv.snp.right).offset(2)
            make.centerY.equalTo(lightValueIv)
        }
        
        originLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lightValueLabel.snp.right).offset(2)
            make.centerY.equalTo(lightValueLabel)
        }
        
        ownerIv.snp.makeConstraints { (make) in
            make.right.equalTo(titleLabel)
            make.centerY.equalTo(lightValueIv)
            make.size.equalTo(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
