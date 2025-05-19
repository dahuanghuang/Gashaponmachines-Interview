import Kingfisher

class SettingsSubTitleCell: BaseTableViewCell {

    var titleLabel: UILabel = {
        let label = UILabel.with(textColor: .black, fontSize: 28)
        label.numberOfLines = 1
        return label
    }()

    var subTitleLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_lightGray, fontSize: 28)
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let topMaskView = UIView.withBackgounrdColor(.white)
        contentView.addSubview(topMaskView)
        topMaskView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(12)
            make.centerY.equalTo(self.contentView)
        }

        self.contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
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

    func configureWith(_ setting: Setting, isLast: Bool) {

        if setting == .clearCache {
            getAllDiskCacheSize()
        }
        self.titleLabel.text = setting.title
        
        self.layer.cornerRadius = isLast ? 12 : 0
    }

    private func getAllDiskCacheSize() {
//        KingfisherManager.shared.cache.calculateDiskCacheSize { size in
//            let float: Float = Float(size) / (1024.0 * 1024.0)
//            self.subTitleLabel.text = String(format: "%.1f", float) + "M"
//        }
//        self.subTitleLabel.text = "0M"

    }
}
