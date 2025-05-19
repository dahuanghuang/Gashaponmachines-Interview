class InviteTableViewCell: BaseTableViewCell {

    let titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    let avatar = UIImageView()

    let valueLabel = UILabel.with(textColor: .qu_orange, boldFontSize: 28)

    let emptyLabel = UILabel.with(textColor: .qu_lightGray, boldFontSize: 24)

    let invalidLabel = UIButton.with(title: "未扭蛋", titleColor: .qu_lightGray, fontSize: 22)

    let container = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .qu_yellow

        let contentView = UIView.withBackgounrdColor(.white)
        self.contentView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(8)
            make.right.equalTo(self.contentView).offset(-8)
            make.top.bottom.equalTo(self.contentView)
        }

        contentView.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.top.equalTo(contentView).offset(12)
            make.bottom.equalTo(contentView).offset(-12)
            make.left.equalTo(contentView).offset(20)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatar)
            make.left.equalTo(avatar.snp.right).offset(8)
        }

        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatar)
            make.right.equalTo(contentView).offset(-20)
        }

        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.right.equalTo(contentView).offset(-20)
            make.centerY.equalTo(contentView)
        }

        emptyLabel.textAlignment = .center
        container.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.right.top.equalTo(container)
        }

        container.addSubview(invalidLabel)
        invalidLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel.snp.bottom).offset(4)
            make.bottom.right.equalTo(container)
            make.width.equalTo(55)
            make.height.equalTo(16)
            make.centerX.equalTo(emptyLabel)
        }

        emptyLabel.text = "+0\(AppEnvironment.reviewKeyWord)"
        invalidLabel.setBackgroundColor(color: .viewBackgroundColor, forUIControlState: .normal)
    	invalidLabel.layer.cornerRadius	= 8
        invalidLabel.layer.masksToBounds = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(friend: InvitedFriend) {
        avatar.gas_setImageWithURL(friend.avatar)
        titleLabel.text = friend.nickname
        container.isHidden = friend.hasFinishedInvitation
        valueLabel.isHidden = !friend.hasFinishedInvitation
        valueLabel.text = "+\(friend.giftBalance)\(AppEnvironment.reviewKeyWord)"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.cancelNetworkImageDownloadTask()
    }
}
