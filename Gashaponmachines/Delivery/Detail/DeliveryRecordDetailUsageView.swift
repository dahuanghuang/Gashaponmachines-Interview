class DeliveryRecordDetailUsageView: UIView {

    init(usage: String) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        
        let label = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "使用说明")
        label.numberOfLines = 1
        label.preferredMaxLayoutWidth = Constants.kScreenWidth - 24
        self.addSubview(label)

        let height = UIFont.heightOfPixel(28)
        label.snp.makeConstraints { make in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self).offset(12)
            make.height.equalTo(height)
        }

        let usageLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: usage)
        usageLabel.setLineSpacing(lineHeightMultiple: 1.5)
        usageLabel.numberOfLines = 0
        usageLabel.preferredMaxLayoutWidth = Constants.kScreenWidth - 24
        self.addSubview(usageLabel)
        usageLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.left.equalTo(self).offset(12)
            make.right.equalTo(self).offset(-12)
            make.bottom.equalTo(self).offset(-20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
