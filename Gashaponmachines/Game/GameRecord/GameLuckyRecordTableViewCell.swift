import UIKit

class GameLuckyRecordTableViewCell: BaseTableViewCell {

    let icon = UIImageView()

    let avatarFrame = UIImageView()

    let titleLabel = UILabel.with(textColor: .black, boldFontSize: 28)

    let timeLabel = UILabel.with(textColor: .new_middleGray, fontSize: 20)
    /// 暴击图片
    let critIv = UIImageView(image: UIImage(named: "crit_lucky_record"))
    /// 暴击个数
    lazy var critCountLb: UILabel = {
        let lb = UILabel.numberFont(size: 12)
        lb.textColor = .black
        lb.textAlignment = .center
        lb.backgroundColor = UIColor(hex: "FFCC3E")
        lb.layer.cornerRadius = 8
        lb.layer.masksToBounds = true
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        icon.layer.cornerRadius = 22
        icon.layer.masksToBounds = true
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.left.equalTo(self.contentView).offset(24)
            make.centerY.equalTo(self.contentView)
        }

        contentView.addSubview(avatarFrame)
        avatarFrame.snp.makeConstraints { make in
            make.edges.equalTo(icon)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(icon).offset(4)
            make.left.equalTo(icon.snp.right).offset(8)
        }

        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(icon).offset(-4)
        }

        contentView.addSubview(critIv)
        critIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-24)
            make.size.equalTo(52)
        }

        critIv.addSubview(critCountLb)
        critCountLb.snp.makeConstraints { make in
            make.centerX.bottom.equalTo(critIv)
            make.width.equalTo(40)
            make.height.equalTo(16)
        }

        let line = UIView.withBackgounrdColor(.new_backgroundColor.alpha(0.4))
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(icon)
            make.right.equalTo(critIv)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    func configureWith(record: LuckyEggRecordEnvelope.Record) {
        self.titleLabel.text = record.nickname
        self.timeLabel.text = record.luckyTime
        self.icon.gas_setImageWithURL(record.avatar)
        self.avatarFrame.gas_setImageWithURL(record.avatarFrame)
        if let critMultiple = record.critMultiple, let IntCM = Int(critMultiple) {
            self.critCountLb.text = "x\(IntCM)"
            self.critCountLb.isHidden = false
            self.critIv.isHidden = false
        } else {
            self.critCountLb.isHidden = true
            self.critIv.isHidden = true
        }
    }

    override func prepareForReuse() {
        self.icon.cancelNetworkImageDownloadTask()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
