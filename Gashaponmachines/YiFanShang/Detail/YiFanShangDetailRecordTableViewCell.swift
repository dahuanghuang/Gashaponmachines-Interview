class YiFanShangDetailRecordTableViewCell: BaseTableViewCell {

    lazy var avatar = UIImageView()

    lazy var avatarFrame = UIImageView()

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    lazy var timeLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    lazy var numberLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    let magicIv = UIImageView()

//    lazy var numberView = UIImageView()

    let timeLabelWidth = (Constants.kScreenWidth - 24) / 4

    let container = UIView.withBackgounrdColor(.white)

    var isEvenNumber: Bool = true {
        didSet {
            container.backgroundColor = isEvenNumber ? .white : UIColor.viewBackgroundColor
            bottomContaier.backgroundColor = container.backgroundColor
            topContaier.backgroundColor = container.backgroundColor
        }
    }
    
    let topContaier = UIView.withBackgounrdColor(.white)
    let bottomContaier = UIView.withBackgounrdColor(.white)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear

        container.layer.cornerRadius = 12
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.bottom.equalToSuperview()
        }

        container.addSubview(topContaier)
        topContaier.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        container.addSubview(bottomContaier)
        bottomContaier.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        container.addSubview(avatar)
        avatar.layer.cornerRadius = 24
        avatar.layer.masksToBounds = true
        avatar.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        container.addSubview(avatarFrame)
        avatarFrame.snp.makeConstraints { make in
            make.edges.equalTo(avatar)
        }

        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(timeLabelWidth * 2 - 36 - 48)
        }

        let timeLabelContainer = UIView()
        container.addSubview(timeLabelContainer)
        timeLabelContainer.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(timeLabelWidth)
        }

        timeLabelContainer.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        let numberViewContainer = UIView()
        container.addSubview(numberViewContainer)
        numberViewContainer.snp.makeConstraints { make in
            make.left.equalTo(timeLabelContainer.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(timeLabelWidth)
        }

        numberViewContainer.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        numberViewContainer.addSubview(magicIv)
        magicIv.snp.makeConstraints { (make) in
            make.center.equalTo(numberLabel)
            make.size.equalTo(37)
        }
    }

    func configureWith(ticket: Ticket, isLast: Bool) {
        clean()
        
        bottomContaier.isHidden = isLast

        titleLabel.text = ticket.nickname
        avatar.gas_setImageWithURL(ticket.avatar)
        avatarFrame.gas_setImageWithURL(ticket.avatarFrame)
        timeLabel.text = ticket.purchaseTimeStr

        if let purchaseCount = ticket.purchaseCount {
            numberLabel.text = "x\(purchaseCount)"
        }
        if let number = ticket.number {
            magicIv.image = UIImage(named: "yfs_magic_ticket_\(number)")
        }
    }

    func clean() {
        titleLabel.text = ""
        avatar.image = nil
        avatarFrame.image = nil
        timeLabel.text = ""
        numberLabel.text = ""
        magicIv.image = nil
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
