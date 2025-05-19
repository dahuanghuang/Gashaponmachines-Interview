import UIKit

final class MallRecordCell: BaseTableViewCell {

    var decrease: String? {
        didSet {
            self.valueLabel.text = "-\(decrease ?? "0")蛋壳"
        }
    }

    var titleLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 28)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    var subTitleLabel: UILabel = {
        let label = UILabel.with(textColor: .new_gray, fontSize: 20)
        label.numberOfLines = 1
        return label
    }()

    var valueLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 28)
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    // 遮cell底部圆角视图
    let topMaskView = UIView.withBackgounrdColor(.white)
    let bottomMaskView = UIView.withBackgounrdColor(.white)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        
        contentView.addSubview(topMaskView)
        topMaskView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        contentView.addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(12)
            make.right.equalTo(valueLabel.snp.left).offset(-12)
        }
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
        }

        let line = UIView.seperatorLine()
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    func configureWith(record: MallProductExchangeRecordsEnvelope.Record, isFirst: Bool, isLast: Bool) {
        self.titleLabel.text = record.title
        self.subTitleLabel.text = record.exchangeTime
        self.decrease = record.decrease
        
        if isFirst && isLast { // 只有一行
            topMaskView.isHidden = true
            bottomMaskView.isHidden = true
        } else { // 非一行
            if isFirst { // 第一行
                topMaskView.isHidden = true
                bottomMaskView.isHidden = false
            }else if !isFirst && !isLast { // 中间行
                topMaskView.isHidden = false
                bottomMaskView.isHidden = false
            }else if isLast { // 最后一行
                topMaskView.isHidden = false
                bottomMaskView.isHidden = true
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
