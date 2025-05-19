class ReportReasonCell: BaseTableViewCell {

    var selectIndicator = UIImageView(image: UIImage(named: "login_unselect"))

    var titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(12)
        }

        self.contentView.addSubview(selectIndicator)
        selectIndicator.snp.makeConstraints { make in
            make.right.equalTo(self.contentView).offset(-12)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(25)
        }

        let line = UIView.seperatorLine()
        self.contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }

    override var isSelected: Bool {
        didSet {
            self.selectIndicator.image = isSelected ? UIImage(named: "login_selected") : UIImage(named: "login_unselect")
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
