import UIKit

class HomeRecommendThemeCell: UICollectionViewCell {

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
    let lightValueLabel = UILabel.numberFont(size: 16)
    /// 领养人头像
    lazy var ownerIv: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 6
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        setupUI()
    }

    func setupUI() {
        contentView.addSubview(productIv)
        productIv.addSubview(machineStatusIv)
        productIv.addSubview(machineTypeIv)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lightValueIv)
        contentView.addSubview(lightValueLabel)
        contentView.addSubview(ownerIv)
    }

    func config(machine: HomeMachine) {

        clean()

        productIv.gas_setImageWithURL(machine.image)
        machineTypeIv.image = UIImage(named: machine.type.image)
        machineStatusIv.image = UIImage(named: machine.status.small_image)
        titleLabel.text = machine.title
        lightValueLabel.text = machine.priceStr

        if let owner = machine.owner {
            ownerIv.gas_setImageWithURL(owner.avatar)
            ownerIv.isHidden = false
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
            make.top.left.equalTo(4)
            make.right.equalTo(-4)
            make.height.equalTo(productIv.snp.width)
        }
        
        machineStatusIv.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
        }
        
        machineTypeIv.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(productIv.snp.bottom).offset(2)
            make.left.right.equalTo(productIv)
        }
        
        lightValueIv.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(-9)
            make.size.equalTo(12)
        }
        
        lightValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lightValueIv.snp.right).offset(2)
            make.centerY.equalTo(lightValueIv)
        }
        
        ownerIv.snp.makeConstraints { (make) in
            make.top.equalTo(lightValueIv.snp.bottom).offset(12)
            make.left.equalTo(lightValueIv)
            make.size.equalTo(12)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
