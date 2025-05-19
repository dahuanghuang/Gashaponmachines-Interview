import UIKit

let HomeRecommendWaterFlowCellId = "HomeRecommendWaterFlowCellId"

class HomeRecommendWaterFlowCell: UICollectionViewCell {

    let cellW = (Constants.kScreenWidth - 20)/2

    /// 商品图片
    let productIv = UIImageView()
    /// 机台类型图片
    let machineTypeIv = UIImageView()
    /// 机台状态图片
    let machineStatusIv = UIImageView()
    /// 标题
    lazy var titleLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, fontSize: 26)
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
    /// 标签视图
    var tagView: HomeTagView?
    /// 领养人头像
    lazy var ownerIv: UIImageView = {
        let iv = UIImageView()
        iv.isHidden = true
        iv.layer.cornerRadius = 6
        iv.layer.masksToBounds = true
        return iv
    }()
    /// 领养人昵称
    let ownerLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 20)

    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        contentView.addSubview(productIv)
        productIv.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
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

        contentView.addSubview(ownerIv)

        ownerLabel.isHidden = true
        contentView.addSubview(ownerLabel)
        ownerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(ownerIv.snp.right).offset(4)
            make.centerY.equalTo(ownerIv)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(machine: HomeMachine, index: Int) {
        
        clean()
        
//        var machine = machine
//        machine.originalPrice = "123"
//        machine.owner = HomeMachineOwner(nickname: "哈哈哈", avatar: machine.image)
//        machine.status = .game
//        machine.machineTags = ["预售", "新配置", "哦哦集集乐", "你lds你~", "哦哦集集乐", "哦哦集集乐", "哦哦集集乐", "哦哦集集乐"]

        productIv.gas_setImageWithURL(machine.image)

        machineTypeIv.image = UIImage(named: machine.type.image)

        machineStatusIv.image = UIImage(named: machine.status.large_image)

        titleLabel.text = machine.title
        titleLabel.setLineSpacing(lineHeightMultiple: 1.15)

        lightValueLabel.text = machine.priceStr

        // 原价
        if let originPrice = machine.originalPrice {
            let attrStr = NSAttributedString(string: originPrice, attributes: [NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)])
            originLabel.attributedText = attrStr
            originLabel.isHidden = false
            lightValueLabel.textColor = .new_discountColor
        } else {
            originLabel.isHidden = true
            lightValueLabel.textColor = .qu_black
        }

        // 领养
        if let owner = machine.owner {
            ownerIv.isHidden = false
            ownerLabel.isHidden = false
            ownerIv.gas_setImageWithURL(owner.avatar)
            ownerLabel.text = owner.nickname
        } else {
            ownerIv.isHidden = true
            ownerLabel.isHidden = true
        }

        layoutContentView(machine: machine)
    }

    func layoutContentView(machine: HomeMachine) {

        let isHaveOwner = machine.owner != nil
        var isHaveTag = false
        if let tags = machine.machineTags, !tags.isEmpty {
            isHaveTag = true
        }
        
        lightValueIv.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalTo(titleLabel)
//            make.size.equalTo(12)
            if !isHaveOwner && !isHaveTag {
                make.bottom.equalToSuperview().offset(-12)
            }
        }

        // 标签
        if let tags = machine.machineTags, !tags.isEmpty {
            tagView = HomeTagView(tags: tags)
            contentView.addSubview(tagView!)
            tagView!.snp.makeConstraints { (make) in
                make.top.equalTo(lightValueIv.snp.bottom).offset(12)
                make.left.equalTo(6)
                make.right.equalTo(-6)
                make.height.equalTo(tagView!.contentH)
                if !isHaveOwner {
                    make.bottom.equalToSuperview().offset(-12)
                }
            }
        }

        // 领养机台
        if isHaveOwner {
            ownerIv.snp.makeConstraints { (make) in
                if isHaveTag {
                    make.top.equalTo(tagView!.snp.bottom).offset(8)
                }else {
                    make.top.equalTo(lightValueIv.snp.bottom).offset(12)
                }
                make.left.equalTo(lightValueIv)
                make.size.equalTo(12)
                make.bottom.equalToSuperview().offset(-12)
            }
        }
    }

    func clean() {
        
        productIv.image = nil
        machineTypeIv.image = nil
        machineStatusIv.image = nil
        titleLabel.text = ""
        
        lightValueLabel.text = ""
        lightValueIv.snp_removeConstraints()
        
        tagView?.snp_removeConstraints()
        tagView?.removeFromSuperview()
        tagView = nil
        
        ownerIv.image = nil
        ownerIv.snp_removeConstraints()
        ownerLabel.text = ""
    }
}

class HomeTagView: UIView {

    /// 标签Label数组
    var tagLabels = [UILabel]()

    /// 标签数组
    var tags: [String]!

    /// 总高度
    var contentH: CGFloat = 0

    init(tags: [String]) {
        super.init(frame: .zero)
        self.tags = tags
        self.backgroundColor = .clear

        setupUI()
    }

    func setupUI() {
        
        if self.tags.isEmpty { return }

        for tag in tags {
            /// 定制颜色
            var color: UIColor
            if tag.count == 2 {
                color = UIColor(hex: "D29F26")!
            }else if tag.count == 3 {
                color = UIColor(hex: "FF758D")!
            }else if tag.count == 5 {
                color = UIColor(hex: "7583FF")!
            }else {
                color = .green
            }
            
            // 创建label
            let tagLabel = UILabel.with(textColor: color, fontSize: 16)
            tagLabel.layer.cornerRadius = 4
            tagLabel.layer.masksToBounds = true
            tagLabel.text = tag
            tagLabel.textAlignment = .center
            tagLabel.backgroundColor = color.alpha(0.2)
            self.addSubview(tagLabel)
            tagLabels.append(tagLabel)
        }

//        self.layoutIfNeeded()
        setupFrames()
    }

    func setupFrames() {

        var x: CGFloat = 0
        var y: CGFloat = 0
        let h: CGFloat = 12
        let interitemSpace: CGFloat = 4 // 列间距
        let lineSpace: CGFloat = 4 // 行间距
        var row: CGFloat = 1 // 行数

        for tagLabel in tagLabels {
            // 当前行剩余距离
            let leftMargin = ((Constants.kScreenWidth - 32)/2 - 12) - x

            let w = tagLabel.text!.sizeOfString(usingFont: UIFont.systemFont(ofSize: 8)).width + 8
            
            if leftMargin < w { // 剩余距离不够, 换行
                x = 0
                y = (lineSpace + h) * row
                row += 1
            }
            
            tagLabel.frame = CGRect(x: x, y: y, width: w, height: h)
            
            x = x + interitemSpace + w
        }
        contentH = row * (h + 4) - 4
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
