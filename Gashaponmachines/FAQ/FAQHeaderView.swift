import UIKit

class FAQHeaderView: UIView {
    
    let view1 = FAQDescriptionView()
    
    let view2 = FAQDescriptionView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.addSubview(view1)
        view1.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        self.addSubview(view2)
        view2.snp.makeConstraints { make in
            make.top.equalTo(view1.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        let questionView = UIView.withBackgounrdColor(.clear)
        self.addSubview(questionView)
        questionView.snp.makeConstraints { make in
            make.top.equalTo(view2.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalTo(-8)
        }
        
        let questionLb = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "猜你想问")
        questionView.addSubview(questionLb)
        questionLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(24)
        }
    }
    
    func configureWith(faqs: [FAQEnvelope.FAQ]) {
        if faqs.count < 2 { return }
        view1.configureWith(faq: faqs[0], index: 0)
        view2.configureWith(faq: faqs[1], index: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class FAQDescriptionView: UIView {

    let container = UIView()
    
    let numberLabel = UILabel.with(textColor: .qu_black, boldFontSize: 26)
    
    let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 26)

    let detailLabel = UILabel.with(textColor: .new_gray, fontSize: 24)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .clear

        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
        }
 
        numberLabel.backgroundColor = .new_bgYellow
        numberLabel.layer.cornerRadius = 8
        numberLabel.numberOfLines = 1
        numberLabel.textAlignment = .center
        numberLabel.lineBreakMode = .byWordWrapping
        numberLabel.layer.masksToBounds = true
        container.addSubview(numberLabel)
        numberLabel.snp.remakeConstraints { make in
            make.top.equalTo(12)
            make.left.equalTo(8)
            make.size.equalTo(16)
        }
        
        container.addSubview(titleLabel)
        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(6)
            make.centerY.equalTo(numberLabel)
        }
        
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.preferredMaxLayoutWidth = Constants.kScreenWidth - 65
        container.addSubview(detailLabel)
        detailLabel.snp.remakeConstraints { make in
            make.top.equalTo(numberLabel.snp.bottom).offset(12)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-12)
            make.bottom.equalTo(-12)
        }
    }
    
    func configureWith(faq: FAQEnvelope.FAQ, index: Int) {
        self.titleLabel.text = faq.question
        self.numberLabel.text = "\(index+1)"
        detailLabel.text = faq.answer
        detailLabel.setLineSpacing(lineHeightMultiple: 1.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
