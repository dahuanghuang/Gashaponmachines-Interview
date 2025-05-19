class CompositionRecordCollectionCell: UICollectionViewCell {

    static let width = (Constants.kScreenWidth - 48) / 3

    static let height = width + 4 + UIFont.heightOfBoldPixel(24) + 8 + UIFont.heightOfPixel(20) + 8

    lazy var image = UIImageView()

    lazy var titleLabel: UILabel = {
       	let label = UILabel.with(textColor: .qu_black, boldFontSize: 24)
        label.numberOfLines = 1
        return label
    }()

    lazy var priceLabel: UILabel = {
       	let label = UILabel.with(textColor: UIColor(hex: "ff7645")!, fontSize: 20)
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.backgroundColor = .white
        self.contentView.addSubview(image)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(priceLabel)

        image.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.size.equalTo(CompositionRecordCollectionCell.width)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        roundCorners(.allCorners, radius: 8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(record: ComposeRecord) {
        self.image.gas_setImageWithURL(record.image)
        self.titleLabel.text = record.title
        self.priceLabel.text = "省 \(record.savingCount) 蛋壳"
    }
}
