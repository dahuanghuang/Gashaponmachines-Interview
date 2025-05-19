class ConfirmDeliveryTableViewCell: BaseTableViewCell {

    let bgView = UIView.withBackgounrdColor(.white)

    let topCover = UIView.withBackgounrdColor(.white)
    
    let bottomCover = UIView.withBackgounrdColor(.white)
    
    let iv = UIImageView()

    let icon = UIImageView()

    let titleLabel = UILabel.with(textColor: UIColor.qu_black, boldFontSize: 28)

    let countLabel = UILabel.with(textColor: UIColor.qu_lightGray, fontSize: 24)
    
    let valueIv = UIImageView(image: UIImage(named: "mall_egg"))
    
    let valueLb = UILabel.with(textColor: .black, boldFontSize: 28)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        bgView.layer.cornerRadius = 12
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        
        topCover.isHidden = true
        bgView.addSubview(topCover)
        topCover.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        bottomCover.isHidden = true
        bgView.addSubview(bottomCover)
        bottomCover.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }

        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        bgView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.width.equalTo(iv.snp.height)
        }

        iv.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.left.bottom.equalTo(iv)
        }

        titleLabel.numberOfLines = 2
        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iv).offset(4)
            make.left.equalTo(iv.snp.right).offset(8)
            make.right.equalTo(-34)
        }

        bgView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(iv).offset(-4)
        }
        
        valueLb.isHidden = true
        valueLb.textAlignment = .right
        bgView.addSubview(valueLb)
        valueLb.snp.makeConstraints { make in
            make.centerY.equalTo(countLabel)
            make.right.equalTo(-16)
        }
        
        valueIv.isHidden = true
        bgView.addSubview(valueIv)
        valueIv.snp.makeConstraints { make in
            make.centerY.equalTo(valueLb)
            make.right.equalTo(valueLb.snp.left).offset(-2)
            make.size.equalTo(16)
        }
    }

    func configureWith(product: ShipInfoEnvelope.ShipProduct, style: ConfirmDeliveryStyle, worth: Int, count: Int, isFirst: Bool, isLast: Bool) {

        if let image = product.image {
            iv.gas_setImageWithURL(image)
        }

        if let iconURLStr = product.icon {
            icon.gas_setImageWithURL(iconURLStr)
        }

        titleLabel.text = product.title

        if style == .eggProduct {
            countLabel.text = "✕\(product.count)"
            valueIv.isHidden = true
            valueLb.isHidden = true
        } else {
            countLabel.text = "✕\(count)"
            valueIv.isHidden = false
            valueLb.isHidden = false
            valueLb.text = "\(worth)"
        }
        
        if isFirst && isLast { // 只有一个
            topCover.isHidden = true
            bottomCover.isHidden = true
        }else if isFirst {
            topCover.isHidden = true
            bottomCover.isHidden = false
        }else if isLast {
            topCover.isHidden = false
            bottomCover.isHidden = true
        }else if !isFirst && !isLast {
            topCover.isHidden = false
            bottomCover.isHidden = false
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        icon.cancelNetworkImageDownloadTask()
        iv.cancelNetworkImageDownloadTask()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
