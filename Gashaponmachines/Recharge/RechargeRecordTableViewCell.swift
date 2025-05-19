import UIKit

final class RechargeRecordTableViewCell: BaseTableViewCell {
    
    var increase: String? {
        didSet {
            self.valueLabel.textColor = .new_orange
            self.valueLabel.text = "+\(increase ?? "0")\(AppEnvironment.reviewKeyWord)"
        }
    }

    var decrease: String? {
        didSet {
            self.valueLabel.textColor = .qu_black
            self.valueLabel.text = "-\(decrease ?? "0")\(AppEnvironment.reviewKeyWord)"
        }
    }

    var titleLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 28)
        label.numberOfLines = 1
        return label
    }()

    var subTitleLabel: UILabel = {
        let label = UILabel.with(textColor: .new_gray, fontSize: 20)
        label.numberOfLines = 1
        return label
    }()

    var valueLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 28)
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .white
        
        // 遮cell底部圆角
        let maskView = UIView.withBackgounrdColor(.white)
        self.addSubview(maskView)
        maskView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(20)
        }

        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
        }

        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }

        let line = UIView.withBackgounrdColor(.new_lightGray.alpha(0.5))
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(valueLabel)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    func configureWith(record: BalanceLogEnvelope.BalanceLog, isFirst: Bool) {
        self.titleLabel.text = record.description
        self.subTitleLabel.text = record.createdAt
        if let increase = record.increase {
            self.increase = increase
        } else if let decrease = record.decrease {
            self.decrease = decrease
        }
        
        self.layer.cornerRadius = isFirst ? 12: 0
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
