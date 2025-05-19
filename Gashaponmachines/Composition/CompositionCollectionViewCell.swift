class CompositionCollectionViewCell: UICollectionViewCell {

    lazy var imageView = UIImageView()

    lazy var labelView = UIImageView()

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    lazy var originPriceLabel = UILabel.with(textColor: UIColor.qu_lightGray, fontSize: 20)

    lazy var compositionPriceLabel = UILabel.with(textColor: UIColor(hex: "ff7645")!, fontSize: 20)

    lazy var progressView = CompositionProgressView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.backgroundColor = .white

        self.contentView.addSubview(imageView)

        self.contentView.addSubview(labelView)

        self.contentView.addSubview(titleLabel)

        self.contentView.addSubview(originPriceLabel)

        self.contentView.addSubview(compositionPriceLabel)

        self.contentView.addSubview(progressView)

        imageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.contentView)
            make.size.equalTo(CompositionCollectionViewCellWidth)
        }

        labelView.snp.makeConstraints { make in
            make.top.right.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 134/2, height: 20))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.left.equalTo(self.contentView).offset(8)
            make.right.equalTo(self.contentView).offset(-8)
        }

        compositionPriceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }

        originPriceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(compositionPriceLabel)
            make.left.equalTo(compositionPriceLabel.snp.right).offset(5)
        }

        let label = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "进度")
        self.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(originPriceLabel.snp.bottom).offset(16)
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(self.contentView).offset(-16)
        }

        progressView.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.left.equalTo(label.snp.right).offset(4)
            make.right.equalTo(self.contentView).offset(-8)
            make.height.equalTo(8)
        }
    }

    func configureWith(path: ComposePath) {
        titleLabel.text = path.title
        originPriceLabel.addStrikeThroughLine(with: "\(path.worth) 蛋壳")
        compositionPriceLabel.text = "\(path.originalWorth) 蛋壳"

//        let yellow = Float(path.progress.lockMaterialCount) / Float(path.progress.totalMaterialCount)
        let blue = Float(path.progress.ownMaterialCount) / Float(path.progress.totalMaterialCount)
//        progressView.yellowValue = yellow
        progressView.blueValue = blue

        imageView.gas_setImageWithURL(path.image)
        labelView.gas_setImageWithURL(path.label)
        progressView.progressStr = path.progress.percentage
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        roundCorners(.allCorners, radius: 8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
