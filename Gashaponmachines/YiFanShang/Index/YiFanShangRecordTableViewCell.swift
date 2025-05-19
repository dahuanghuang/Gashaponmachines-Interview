class YiFanShangRecordTableViewCell: UITableViewCell {

    lazy var serialLabel = UILabel.with(textColor: .new_gray, fontSize: 24)
    
    lazy var countLabel = UILabel.with(textColor: .new_gray, fontSize: 24)

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    lazy var dateLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 20)

    lazy var valueChangeLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .new_backgroundColor
        
        let whiteBgView = UIView.withBackgounrdColor(.white)
        whiteBgView.layer.cornerRadius = 12
        contentView.addSubview(whiteBgView)
        whiteBgView.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
        }
        
        whiteBgView.addSubview(serialLabel)
        serialLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalToSuperview()
            make.height.equalTo(34)
        }
        
        countLabel.textAlignment = .right
        whiteBgView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(serialLabel)
        }
        
        titleLabel.numberOfLines = 0
        whiteBgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(serialLabel.snp.bottom)
            make.height.equalTo(52)
        }

        whiteBgView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(12)
            make.height.equalTo(34)
        }

        valueChangeLabel.textAlignment = .right
        whiteBgView.addSubview(valueChangeLabel)
        valueChangeLabel.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(dateLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(record: YiFanShangRecord) {

        cleanData()

        if let serial = record.serial {
            serialLabel.text = "第\(serial)弹"
        }

        if let title = record.title {
            titleLabel.text = "\(title)"
        }
        
        if let count = record.purchaseCount {
            let totalStr = "共 \(count) 件"
            let string = NSMutableAttributedString(string: totalStr, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: UIColor.new_gray
                ])
            let range = totalStr.range(of: "\(count)")!
            let nsRange = NSRange(range, in: totalStr)
            string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.new_orange], range: nsRange)
            countLabel.attributedText = string
        }

        dateLabel.text = record.purchaseTimeStr

        if let increase = record.increase, increase != "0" {
            valueChangeLabel.text = "+ \(increase) 元气"
        } else if let decrease = record.decrease {
            valueChangeLabel.text = "- \(decrease) 元气"
        }
    }

    func cleanData() {
        serialLabel.text = ""
        titleLabel.text = ""
        dateLabel.text = ""
        valueChangeLabel.text = ""
    }
}
