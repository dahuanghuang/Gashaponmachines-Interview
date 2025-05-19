import UIKit

final class GameRecordTableViewCell: BaseTableViewCell {

    /// 白色圆角背景
    lazy var whiteBgView: UIView = {
        let view = UIView.withBackgounrdColor(.white)
        view.layer.cornerRadius = 12
        return view
    }()
    /// 商品图片
    lazy var productIv: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        return iv
    }()
    /// 扭蛋 icon
    var eggIcon = UIImageView()
    /// 机台样式图片
    let machineIcon = UIImageView()
    /// 机台图片
    lazy var machineItemIcon: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 7
        iv.layer.masksToBounds = true
        return iv
    }()
    /// 商品名称
    var titleLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 28)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    /// 日期
    var dateLabel: UILabel = {
        let label = UILabel.with(textColor: .new_middleGray, fontSize: 24)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    /// 能量
    var obtainPowerLabel: UILabel = {
        let label = UILabel.with(textColor: .new_orange, boldFontSize: 24)
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    /// 暴击倍数
    var critCountLabel: UILabel = {
        let label = UILabel.with(textColor: UIColor(hex: "f7435d")!, fontSize: 20)
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.backgroundColor = .new_backgroundColor

        self.contentView.addSubview(whiteBgView)
        whiteBgView.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
        }

        whiteBgView.addSubview(productIv)
        productIv.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.width.equalTo(productIv.snp.height)
        }
        
        whiteBgView.addSubview(machineIcon)
        machineIcon.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalTo(26)
            make.height.equalTo(32)
        }

        machineIcon.addSubview(machineItemIcon)
        machineItemIcon.snp.makeConstraints { make in
            make.top.left.equalTo(2)
            make.right.equalTo(-2)
            make.height.equalTo(machineItemIcon.snp.width)
        }

        productIv.addSubview(eggIcon)
        eggIcon.snp.makeConstraints { make in
            make.top.equalTo(productIv)
            make.left.equalTo(productIv.snp.right).offset(9)
            make.size.equalTo(16)
        }

        whiteBgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(eggIcon.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(eggIcon)
        }
        
        whiteBgView.addSubview(critCountLabel)
        critCountLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }

        whiteBgView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(productIv)
            make.left.equalTo(titleLabel)
        }

        whiteBgView.addSubview(obtainPowerLabel)
        obtainPowerLabel.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(dateLabel)
        }
    }

    func configureWith(record: GameRecordEnvelope.GameRecord) {

        cleanData()

        self.titleLabel.text = record.title
        self.dateLabel.text = record.luckyTime
        self.productIv.gas_setImageWithURL(record.image)
        self.eggIcon.gas_setImageWithURL(record.icon)
        if let machineIcon = record.machineIcon {
            self.machineIcon.gas_setImageWithURL(machineIcon)
        }
        if let machineImage = record.machineImage {
            self.machineItemIcon.gas_setImageWithURL(machineImage)
        }

        if let obtain = record.powerObtain {
            self.obtainPowerLabel.text = "+\(obtain) 能量"
        }
        if let cost = record.powerCost {
            self.obtainPowerLabel.text = "-\(cost) 能量"
        }

        if let critCount = record.critMultiple {
            critCountLabel.text = "暴击额外获得+\(critCount)"
        }
    }

    func cleanData() {
        self.titleLabel.text = ""
        self.dateLabel.text = ""
        self.productIv.image = nil
        self.eggIcon.image = nil
        self.machineIcon.image = nil
        self.machineItemIcon.image = nil
        self.obtainPowerLabel.text = ""
        self.critCountLabel.text = ""
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
