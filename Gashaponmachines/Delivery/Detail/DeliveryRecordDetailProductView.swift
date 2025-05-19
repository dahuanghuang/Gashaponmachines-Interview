class DeliveryRecordDetailProductView: UIView {

    private let icon = UIImageView()
    private let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    private let dateLabel = UILabel.with(textColor: .new_middleGray, fontSize: 24)
    private let countLabel = UILabel.with(textColor: .black, boldFontSize: 28)

    /// 是否为第一个
    private var isFirst = false
    /// 是否为最后一个
    private var isLast = false
    /// 是否有卡号卡密
    private var isCyberInfo = false
    
    init(product: ShipDetailEnvelope.ShipDetailProduct, isFirst: Bool, isLast: Bool, isCyberInfo: Bool) {
        super.init(frame: .zero)
        
        self.isFirst = isFirst
        self.isLast = isLast
        self.isCyberInfo = isCyberInfo

        self.backgroundColor = .white
        
        icon.gas_setImageWithURL(product.image)
        icon.layer.cornerRadius = 8
        icon.layer.masksToBounds = true
        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.top.equalTo(12)
            make.bottom.equalTo(-12)
            make.width.equalTo(icon.snp.height)
        }

        titleLabel.text = product.title
        titleLabel.numberOfLines = 2
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(8)
            make.top.equalTo(icon)
            make.right.equalTo(-12)
        }

        dateLabel.text = product.luckyTime
        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(icon)
            make.left.equalTo(titleLabel)
        }

        countLabel.text = "✕\(product.count)"
        self.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.right.equalTo(-12)
        }
        
        if !isLast {
            let line = UIView.withBackgounrdColor(.new_backgroundColor.alpha(0.4))
            self.addSubview(line)
            line.snp.makeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(1)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFirst && isLast {
            if isCyberInfo {
                self.roundCorners([.topLeft, .topRight], radius: 12)
            }else {
                self.roundCorners(.allCorners, radius: 12)
            }
        }else if isFirst {
            self.roundCorners([.topLeft, .topRight], radius: 12)
        }else if isLast {
            self.roundCorners([.bottomLeft, .bottomRight], radius: 12)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
