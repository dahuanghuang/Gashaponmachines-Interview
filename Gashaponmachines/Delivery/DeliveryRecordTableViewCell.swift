
class DeliveryRecordTableViewCell: BaseTableViewCell {
    
    static let imageViewWH: CGFloat = (Constants.kScreenWidth - 78)/4

    let worthView = DeliveryRecordWorthView()
    
    let container = RoundedCornerView(corners: [.topLeft, .topRight], radius: 12)
    
    let numberLabel = UILabel.with(textColor: UIColor.qu_black, boldFontSize: 28)

    let statusLabel = UILabel.with(textColor: .UIColorFromRGB(0xD29F26), fontSize: 28)
    
    let gradientLayer = CAGradientLayer()

    var imageArray: [UIImageView] = []

    var iconArray: [UIImageView] = []
    
    let countView = UIView.withBackgounrdColor(.black.alpha(0.25))
    
    let countLabel = UILabel.with(textColor: .white, boldFontSize: 28)
    
    let worthLb = UILabel.with(textColor: UIColor(hex: "9A4312")!, boldFontSize: 28)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.backgroundColor = .new_backgroundColor
        
        worthView.isHidden = true
        contentView.addSubview(worthView)
        worthView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(130)
        }

        container.backgroundColor = .white
        self.contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(62 + DeliveryRecordTableViewCell.imageViewWH)
        }

        container.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
			make.top.equalTo(container)
            make.height.equalTo(42)
            make.left.equalTo(container).offset(12)
        }

        container.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.right.equalTo(container).offset(-12)
            make.centerY.equalTo(numberLabel)
            make.height.equalTo(42)
        }
        
        gradientLayer.colors = [UIColor(hex: "FFF7C6")!.alpha(0.2).cgColor, UIColor(hex: "FFF7C6")!.alpha(0.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 42, width: Constants.kScreenWidth-24, height: Self.imageViewWH+20)
        container.layer.addSublayer(gradientLayer)

        let line = UIView.withBackgounrdColor(.new_bgYellow.alpha(0.2))
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(statusLabel.snp.bottom)
        }

        for i in 0...3 {
            let img = UIImageView()
            img.layer.cornerRadius = 8
            img.layer.masksToBounds = true
            container.addSubview(img)
            img.snp.makeConstraints { make in
                make.size.equalTo(Self.imageViewWH)
                make.left.equalTo(container).offset(12 + (10 + Self.imageViewWH) * CGFloat(i))
                make.top.equalTo(line.snp.bottom).offset(8)
                make.bottom.equalTo(container).offset(-12)
            }
            imageArray.append(img)

            let icon = UIImageView()
            img.addSubview(icon)
            icon.snp.makeConstraints { make in
                make.bottom.left.equalTo(img)
                make.size.equalTo(24)
            }
            iconArray.append(icon)
        }
        
        countView.layer.cornerRadius = 8
        container.addSubview(countView)
        countView.snp.makeConstraints { make in
            make.right.bottom.equalTo(-12)
            make.width.equalTo(Self.imageViewWH)
            make.height.equalTo(26)
        }
        
        countView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let worthIv = UIImageView(image: UIImage(named: "delivery_list_worth"))
        contentView.addSubview(worthIv)
        worthIv.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom)
            make.left.right.equalTo(container)
            make.height.equalTo(DeliveryRecordWorthView.height)
        }
        
        worthLb.textAlignment = .right
        worthIv.addSubview(worthLb)
        worthLb.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageArray.forEach { img in
            img.cancelNetworkImageDownloadTask()
        }

        iconArray.forEach { icon in
            icon.cancelNetworkImageDownloadTask()
        }
    }

    func configureWith(info: ShipListEnvelope.ShipInfo, status: DeliveryStatus, isShow: Bool, shipWorth: ShipWorthEnvelope?) {
        
        clean()
        
        self.worthView.isHidden = !isShow
        if let s = shipWorth {
            self.worthView.configureWith(shipWorthEnvelope: s)
        }
        self.container.snp.updateConstraints { make in
            make.top.equalTo(isShow ? 100 : 12)
        }
        
        self.numberLabel.text = "\(info.source)"
        self.statusLabel.text = info.statusString

        zip(info.products.compactMap { $0 }, self.imageArray)
            .forEach {
                $0.1.gas_setImageWithURL($0.0.image)
        	}

        zip(info.products.compactMap { $0 }, self.iconArray)
            .forEach {
                if let iconURLStr = $0.0.icon {
                    $0.1.gas_setImageWithURL(iconURLStr)
                }
        	}
        
        self.countView.isHidden = (info.products.count <= 4)
        self.countLabel.text = "共\(info.products.count)项"
        
        if status == .canceled || status == .received {
            self.statusLabel.textColor = .new_gray
        }else {
            self.statusLabel.textColor = .UIColorFromRGB(0xD29F26)
        }
        
        worthLb.text = "\(info.shipOrderWorth)蛋壳"
    }
    
    func clean() {
        self.worthView.isHidden = true
        self.numberLabel.text = ""
        self.statusLabel.text = ""
        for iv in imageArray { iv.image = nil }
        for icon in iconArray { icon.image = nil }
        self.countView.isHidden = true
        self.countLabel.text = ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class DeliveryRecordWorthView: UIView {
    
    static let height = (Constants.kScreenWidth-24)*0.11
    
    let countLb = UILabel()
    
    let worthLb = UILabel()
    
    var shipWorthEnv: ShipWorthEnvelope?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bgIv = UIImageView(image: UIImage(named: "delivery_list_worth_bg"))
        self.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let titleIv = UIImageView(image: UIImage(named: "delivery_list_worth_title"))
        self.addSubview(titleIv)
        titleIv.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        let leftView = UIView.withBackgounrdColor(.clear)
        bgIv.addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.top.equalTo(36)
            make.left.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        let leftCenterView = UIView.withBackgounrdColor(.clear)
        leftView.addSubview(leftCenterView)
        leftCenterView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(30)
        }
        
        let leftIv = UIImageView(image: UIImage(named: "delivery_lis_count"))
        leftCenterView.addSubview(leftIv)
        leftIv.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        
        leftCenterView.addSubview(countLb)
        countLb.snp.makeConstraints { make in
            make.bottom.equalTo(leftIv)
            make.left.equalTo(leftIv.snp.right).offset(2)
            make.right.equalToSuperview()
        }
        
        let countDescLb = UILabel.with(textColor: UIColor(hex: "9A4312")!, fontSize: 16, defaultText: "发货数量")
        leftCenterView.addSubview(countDescLb)
        countDescLb.snp.makeConstraints { make in
            make.top.equalTo(leftIv)
            make.left.equalTo(countLb)
        }
        
        let rightView = UIView.withBackgounrdColor(.clear)
        bgIv.addSubview(rightView)
        rightView.snp.makeConstraints { make in
            make.top.size.equalTo(leftView)
            make.right.equalToSuperview()
        }
        
        let rightCenterView = UIView.withBackgounrdColor(.clear)
        rightView.addSubview(rightCenterView)
        rightCenterView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(30)
        }
        
        let rightIv = UIImageView(image: UIImage(named: "delivery_lis_danke"))
        rightCenterView.addSubview(rightIv)
        rightIv.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        
        rightCenterView.addSubview(worthLb)
        worthLb.snp.makeConstraints { make in
            make.bottom.equalTo(rightIv)
            make.left.equalTo(rightIv.snp.right).offset(2)
            make.right.equalToSuperview()
        }
        
        let worthDescLb = UILabel.with(textColor: UIColor(hex: "9A4312")!, fontSize: 16, defaultText: "发货价值")
        rightCenterView.addSubview(worthDescLb)
        worthDescLb.snp.makeConstraints { make in
            make.top.equalTo(rightIv)
            make.left.equalTo(worthLb)
        }
        
        let questionIv = UIImageView(image: UIImage(named: "delivery_list_question"))
        self.addSubview(questionIv)
        questionIv.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.top.equalTo(8)
            make.right.equalTo(-8)
        }
        
        /// 该按钮用来覆盖当前视图所在cell的点击事件
        let actionButton = UIButton()
        self.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let questionButton = UIButton()
        questionButton.addTarget(self, action: #selector(questionButtonClick), for: .touchUpInside)
        self.addSubview(questionButton)
        questionButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(32)
        }
    }
    
    func configureWith(shipWorthEnvelope: ShipWorthEnvelope) {
        self.shipWorthEnv = shipWorthEnvelope
        
        let countStr = "\(shipWorthEnvelope.shipCount)件"
        let countAttrStr = NSMutableAttributedString(string: countStr)
        countAttrStr.addAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor(hex: "933500")!,
             NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)],
            range: (countStr as NSString).range(of: "\(shipWorthEnvelope.shipCount)"))
        countAttrStr.addAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor(hex: "9A4312")!,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)],
            range: (countStr as NSString).range(of: "件"))
        countLb.attributedText = countAttrStr
        
        let worthtStr = "\(shipWorthEnvelope.eggWorth)蛋壳"
        let worthAttrStr = NSMutableAttributedString(string: worthtStr)
        worthAttrStr.addAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor(hex: "933500")!,
             NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)],
            range: (worthtStr as NSString).range(of: "\(shipWorthEnvelope.eggWorth)"))
        worthAttrStr.addAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor(hex: "9A4312")!,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)],
            range: (worthtStr as NSString).range(of: "蛋壳"))
        worthLb.attributedText = worthAttrStr
    }
    
    @objc func questionButtonClick() {
        if let link = self.shipWorthEnv?.jumpLink {
            RouterService.route(to: link)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
