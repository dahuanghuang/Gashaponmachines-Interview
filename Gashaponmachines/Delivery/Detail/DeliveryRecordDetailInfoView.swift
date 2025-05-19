class DeliveryRecordDetailInfoView: UIView {

    init(envelope: ShipDetailEnvelope) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        
        let detailLabel = UILabel.with(textColor: .black, boldFontSize: 28, defaultText: "订单详情")
        self.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.height.equalTo(44)
        }
        
        let numberTitleLabel = UILabel.with(textColor: .black, boldFontSize: 24, defaultText: "发货编号")
        self.addSubview(numberTitleLabel)
        numberTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom)
            make.left.equalTo(12)
            make.height.equalTo(40)
        }
        
        let copyButton = CopyButton.roundButton()
        copyButton.params = ["num": envelope.shipNumber]
        copyButton.addTarget(self, action: #selector(copyCardNum(button:)), for: .touchUpInside)
        self.addSubview(copyButton)
        copyButton.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(numberTitleLabel)
            make.width.equalTo(44)
            make.height.equalTo(18)
        }
        
        let numberLabel = UILabel.with(textColor: .new_middleGray, fontSize: 24, defaultText: envelope.shipNumber)
        numberLabel.textAlignment = .right
        self.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.centerY.equalTo(numberTitleLabel)
            make.right.equalTo(copyButton.snp.left).offset(-8)
        }

        let confirmDateTitleLabel = UILabel.with(textColor: .black, boldFontSize: 24, defaultText: "确认时间")
        self.addSubview(confirmDateTitleLabel)
        confirmDateTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(numberTitleLabel.snp.bottom)
            make.left.equalTo(12)
            make.height.equalTo(40)
        }
    
        let confirmDateLabel = UILabel.with(textColor: .new_middleGray, fontSize: 24, defaultText: envelope.confirmDate)
        self.addSubview(confirmDateLabel)
        confirmDateLabel.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(confirmDateTitleLabel)
        }

        let shipDateTitleLabel = UILabel.with(textColor: .black, boldFontSize: 24, defaultText: "发货时间")
        self.addSubview(shipDateTitleLabel)
        shipDateTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        
        let shipDateLabel = UILabel.with(textColor: .new_middleGray, fontSize: 24, defaultText: envelope.shipDate)
        self.addSubview(shipDateLabel)
        shipDateLabel.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(shipDateTitleLabel)
        }
    }
    
    @objc func copyCardNum(button: CopyButton) {
        let paste = UIPasteboard.general
        paste.string = button.params["num"] as? String
        HUD.success(second: 2, text: "复制成功", completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
