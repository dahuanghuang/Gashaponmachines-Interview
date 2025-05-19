import UIKit

/// 机台cell
let HomeMachineCellId = "HomeMachineCellId"

class HomeMachineCell: UICollectionViewCell {

    // cell宽度
    static let cellW = ((Constants.kScreenWidth - 34) / 2)
    // cell高度
    static let cellH = HomeMachineCell.cellW + 82

    /// 商品图片
    let productIv = UIImageView()
    /// 机台类型图片
    let machineTypeIv = UIImageView()
    /// 机台状态图片
    let machineStatusIv = UIImageView()
    /// 商品名
    lazy var titleLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, fontSize: 26)
        lb.numberOfLines = 2
        lb.textAlignment = .left
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
        iv.layer.masksToBounds = true
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        setupUI()
    }

    func setupUI() {
        
        contentView.addSubview(productIv)
        productIv.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(productIv.snp.width)
        }
        
        productIv.addSubview(machineStatusIv)
        machineStatusIv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        productIv.addSubview(machineTypeIv)
        machineTypeIv.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(machineStatusIv)
            make.size.equalTo(28)
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

        contentView.addSubview(ownerIv)
        ownerIv.snp.makeConstraints { (make) in
            make.right.equalTo(titleLabel)
            make.centerY.equalTo(lightValueIv)
            make.size.equalTo(16)
        }
    }

    func config(machine: HomeMachine) {

        clean()

        productIv.gas_setImageWithURL(machine.image)
        machineTypeIv.image = UIImage(named: machine.type.image)
        machineStatusIv.image = UIImage(named: machine.status.large_image)
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
        titleLabel.text = ""
        lightValueLabel.text = ""
        ownerIv.image = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
