class YiFanShangLivestreamTableViewCell: BaseTableViewCell {

    lazy var avatar = UIImageView()

    lazy var avatarFrame = UIImageView()

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    lazy var numberView = UIImageView()

    lazy var rewardView = UIImageView()

    let numberViewWidth = (Constants.kScreenWidth - 24) / 4

    let container = UIView.withBackgounrdColor(.white)

    var isEvenNumber: Bool = true {
        didSet {
            container.backgroundColor = isEvenNumber ? .white : UIColor.viewBackgroundColor
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear

        contentView.addSubview(container)
        container.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(12)
//            make.right.equalToSuperview().offset(-12)
//            make.top.bottom.equalToSuperview()
            make.edges.equalToSuperview()
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
            make.width.equalTo(numberViewWidth * 2 - 36 - 48)
        }

        let numberViewContainer = UIView()
        container.addSubview(numberViewContainer)
        numberViewContainer.snp.makeConstraints { make in
            make.top.bottom.centerY.equalToSuperview()
            make.width.equalTo(numberViewWidth)
            make.left.equalTo(titleLabel.snp.right).offset(12)
        }

        let line1 = UIView.seperatorLine()
        container.addSubview(line1)
        line1.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.left.equalTo(numberViewContainer)
        }

        numberViewContainer.addSubview(numberView)
        numberView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(37)
        }

        let rewardViewContainer = UIView()
        container.addSubview(rewardViewContainer)
        rewardViewContainer.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(numberViewWidth)
            make.left.equalTo(numberViewContainer.snp.right)
        }

        let line2 = UIView.seperatorLine()
        container.addSubview(line2)
        line2.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.left.equalTo(rewardViewContainer)
        }

        rewardViewContainer.addSubview(rewardView)
        rewardView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 57, height: 42))
            make.center.equalToSuperview()
        }
    }

    func configureWith(record: YiFanShangLiveStreamRecord) {
        titleLabel.text = record.nickname
        avatar.gas_setImageWithURL(record.avatar)
        avatarFrame.gas_setImageWithURL(record.avatarFrame)
        if let num = record.number {
            if record.isMagic {
                numberView.image = UIImage(named: "yfs_magic_ticket_\(num)")
            } else {
                numberView.image = UIImage(named: "yfs_ticket_\(num)")
            }
        }

        if let imageUrl = record.imageUrl {
            rewardView.gas_setImageWithURL(imageUrl)
        } else {
            rewardView.image = UIImage(named: "yfs_reward_0")
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
