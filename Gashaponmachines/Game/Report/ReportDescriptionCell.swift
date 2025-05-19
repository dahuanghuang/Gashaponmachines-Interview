class ReportDescriptionCell: BaseTableViewCell {

    var titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    var textView: UITextField = {
       	let tf = UITextField()
        tf.textColor = .qu_black
        tf.font = UIFont.withPixel(28)
        return tf
    }()

    var placeholder: String? {
        didSet {
            if let p = placeholder {
                self.textView.attributedPlaceholder = NSAttributedString(string: p, attributes: [NSAttributedString.Key.foregroundColor: UIColor.qu_lightGray,
                     NSAttributedString.Key.font: UIFont.withPixel(28)])
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.numberOfLines = 1
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(12)
            make.width.equalTo(60)
        }

        self.contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(20)
            make.right.equalTo(self.contentView).offset(-12)
            make.centerY.equalTo(self.contentView)
        }

        let line = UIView.seperatorLine()
        self.contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
