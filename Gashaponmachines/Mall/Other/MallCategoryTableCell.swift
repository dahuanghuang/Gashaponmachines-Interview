private let MallCategoryTableviewCelHeight: CGFloat = 112

class MallCategoryTableCell: BaseTableViewCell {

    var titleLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 28)
        return label
    }()

    var valueLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_orange, fontSize: 28)
        label.numberOfLines = 1
        return label
    }()

    let iv = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        let container = RoundedCornerView(corners: .allCorners, radius: 8, backgroundColor: .white)
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-12)
        }

        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        container.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.width.equalTo(iv.snp.height)
        }

        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iv).offset(4)
            make.left.equalTo(iv.snp.right).offset(8)
            make.right.equalTo(-12)
        }

        container.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iv).offset(-4)
            make.left.equalTo(titleLabel)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(product: MallProduct) {
        self.iv.gas_setImageWithURL(product.image)
        self.titleLabel.text = product.title
        self.valueLabel.text = "\(product.worth) 蛋壳"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.iv.cancelNetworkImageDownloadTask()
    }
}
