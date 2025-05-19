class YiFanShangPurchaseRecordListTableViewCell: UITableViewCell {

    let titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    let dateLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 24)

    let container = UIView.withBackgounrdColor(.white)

//    let seperatorLine = UIView.seperatorLine()

    var ticketIvs = [UIImageView]()

    lazy var magicLb: UILabel = {
        let lb = UILabel.with(textColor: UIColor(hex: "8a8a8a")!, fontSize: 24)
        lb.textAlignment = .right
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear

        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview()
        }

        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(12)
        }

        dateLabel.textAlignment = .right
        container.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(titleLabel)
        }

//        container.addSubview(seperatorLine)
//        seperatorLine.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(44)
//            make.left.right.equalToSuperview()
//            make.height.equalTo(0.5)
//        }

        container.addSubview(magicLb)
    }

    func configureWith(record: YiFanShangPurchaseRecord) {

        self.clean()

        if let count = record.count, let tickets = record.numbers {
            if record.isMagic {
                let attrStrM = NSMutableAttributedString.init(string: "已开启")
                let productCount = NSAttributedString.init(string: "\(count)", attributes: [.foregroundColor: UIColor(hex: "fd4152")!, .font: UIFont.boldSystemFont(ofSize: 12)])
                attrStrM.append(productCount)
                attrStrM.append(NSAttributedString.init(string: "个魔法阵"))
                titleLabel.attributedText = attrStrM
            } else {
                let attrStrM = NSMutableAttributedString.init(string: "购买")
                let productCount = NSAttributedString.init(string: "\(count)", attributes: [.foregroundColor: UIColor(hex: "fd4152")!, .font: UIFont.boldSystemFont(ofSize: 12)])
                attrStrM.append(productCount)
                attrStrM.append(NSAttributedString.init(string: "件商品,获得"))
                let ticketCount = NSAttributedString.init(string: "\(tickets.count)", attributes: [.foregroundColor: UIColor(hex: "fd4152")!, .font: UIFont.boldSystemFont(ofSize: 12)])
                attrStrM.append(ticketCount)
                attrStrM.append(NSAttributedString.init(string: "张赠券"))
                titleLabel.attributedText = attrStrM
            }
        }

        dateLabel.text = record.purchaseTimeStr

        if let cost = record.cost {
            magicLb.text = "共消耗: \(cost)魔法值"
            magicLb.snp.remakeConstraints { (make) in
                make.bottom.right.equalToSuperview().offset(-12)
                make.height.equalTo(12)
            }
        } else {
            magicLb.text = ""
            magicLb.snp.remakeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.right.equalToSuperview().offset(-12)
                make.height.equalTo(0)
            }
        }

        let tickets = record.numbers ?? []
        let rows = tickets.chunks(5)
        let ticketWH: CGFloat = (Constants.kScreenWidth - 80)/5
        for (rowIndex, row) in rows.enumerated() { // 遍历每一行

            let topOffset: CGFloat = 8 + CGFloat(rowIndex) * (ticketWH + 8)

            for (id, ticket) in row.enumerated() { // 遍历每一行的每一个
                let iv = UIImageView()
                if record.isMagic {
                    iv.image = UIImage(named: "yfs_magic_ticket_\(ticket)")
                } else {
                    iv.image = UIImage(named: "yfs_ticket_\(ticket)")
                }
                container.addSubview(iv)
                iv.snp.makeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(topOffset)
                    make.left.equalToSuperview().offset((ticketWH + 8) * CGFloat(id) + 12)
                    make.size.equalTo(ticketWH)
                    if rowIndex == rows.count - 1 { // 最后一行
                        make.bottom.equalTo(magicLb.snp.top).offset(-12)
                    }
                }
                ticketIvs.append(iv)
            }
        }
    }

    func clean() {

        titleLabel.attributedText = NSAttributedString.init(string: "")

        dateLabel.text = ""

        for iv in ticketIvs {
            iv.removeFromSuperview()
        }
        ticketIvs.removeAll()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
