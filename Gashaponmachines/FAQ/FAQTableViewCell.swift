final class FAQTableViewCell: BaseTableViewCell {
    
    let container = UIView()
    
    let actionView = UIView.withBackgounrdColor(.clear)
    
    let questionLabel = UILabel.with(textColor: .black, fontSize: 24)
    
    let arrowIv = UIImageView(image: UIImage(named: "FAQ_arrow_down"))

    let detailLabel = UILabel.with(textColor: .new_gray, fontSize: 24)
    
    let line = UIView.withBackgounrdColor(.new_backgroundColor.alpha(0.4))
    
    let topView = UIView.withBackgounrdColor(.white)
    
    let bottomView = UIView.withBackgounrdColor(.white)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear

        container.backgroundColor = .white
        self.contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(self.contentView)
        }
        
        
        container.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(24)
        }
        
        container.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
        
        container.addSubview(actionView)
        
        actionView.addSubview(questionLabel)
        questionLabel.snp.remakeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        actionView.addSubview(arrowIv)
        arrowIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
            make.size.equalTo(12)
        }
        
        actionView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.preferredMaxLayoutWidth = Constants.kScreenWidth - 65
        container.addSubview(detailLabel)
    }
    
    func configureWith(faq: FAQEnvelope.FAQ, isFirst: Bool, isLast: Bool) {
        
        clean()
        
        self.questionLabel.text = faq.question
        
        guard let isFold = faq.isFold else { return }
        
        detailLabel.text = faq.answer
        detailLabel.setLineSpacing(lineHeightMultiple: 1.5)
        detailLabel.isHidden = isFold
        line.isHidden = !isFold
        
        if isFold {
            arrowIv.image = UIImage(named: "FAQ_arrow_down")
            
            actionView.snp.remakeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(48)
                make.bottom.equalToSuperview()
            }
        }else {
            arrowIv.image = UIImage(named: "FAQ_arrow_up")
            
            actionView.snp.remakeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(48)
            }
            
            detailLabel.snp.remakeConstraints { make in
                make.top.equalTo(actionView.snp.bottom)
                make.left.equalTo(12)
                make.right.equalTo(-12)
                make.bottom.equalTo(-16)
            }
        }
        
        if isFirst {
            self.container.layer.cornerRadius = 12
            self.topView.isHidden = true
            self.bottomView.isHidden = false
        }else if isLast {
            self.container.layer.cornerRadius = 12
            self.topView.isHidden = false
            self.bottomView.isHidden = true
        }else {
            self.container.layer.cornerRadius = 0
            self.topView.isHidden = true
            self.bottomView.isHidden = true
        }
    }
    
    func clean() {
        questionLabel.text = ""
        detailLabel.text = ""
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
