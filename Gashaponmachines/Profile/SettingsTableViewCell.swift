import UIKit

final class SettingsTableViewCell: BaseTableViewCell {

    var titleLabel: UILabel = {
        let label = UILabel.with(textColor: .black, fontSize: 28)
        label.numberOfLines = 1
        return label
    }()

//    var subTitleLabel: UILabel = {
//        let label = UILabel.with(textColor: .qu_black, fontSize: 32)
//        label.numberOfLines = 1
//        return label
//    }()

    let switcher = UISwitch()
    
    let topMaskView = UIView.withBackgounrdColor(.white)
    
    let bottomMaskView = UIView.withBackgounrdColor(.white)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(topMaskView)
        topMaskView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        
        contentView.addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }

        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(12)
            make.centerY.equalTo(self.contentView)
        }

        let line = UIView.seperatorLine()
        self.contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }

        switcher.onTintColor = .qu_yellow
        switcher.isOn = true
        self.contentView.addSubview(switcher)
        switcher.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-12)
        }
    }

    func configureWith(setting: Setting, isLast: Bool, isFirst: Bool) {
        self.titleLabel.text = setting.title
        
        if isLast || isFirst {
            self.layer.cornerRadius = 12
            self.topMaskView.isHidden = isFirst
            self.bottomMaskView.isHidden = isLast
        }else {
            self.layer.cornerRadius = 0
            self.topMaskView.isHidden = false
            self.bottomMaskView.isHidden = false
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
