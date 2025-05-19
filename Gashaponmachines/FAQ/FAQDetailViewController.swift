//class FAQDetailViewController: BaseViewController {
//
//    var faq: FAQEnvelope.FAQ
//
//    init(faq: FAQEnvelope.FAQ) {
//        self.faq = faq
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationItem.title = "常见问题"
//        let bg = UIView.withBackgounrdColor(.white)
//        bg.layer.cornerRadius = 4
//        bg.layer.masksToBounds = true
//        self.view.addSubview(bg)
//        bg.snp.makeConstraints { make in
//            make.top.equalTo(16)
//            make.left.equalTo(12)
//            make.right.equalTo(-12)
//            make.bottom.equalTo(-16)
//        }
//
//        let questionDesLabel = UILabel.with(textColor: .qu_yellow, fontSize: 28, defaultText: "问：")
//       	let ansDesLabel = UILabel.with(textColor: .qu_yellow, fontSize: 28, defaultText: "答：")
//
//    	bg.addSubview(questionDesLabel)
//        questionDesLabel.snp.makeConstraints { make in
//            make.left.equalTo(bg).offset(12)
//            make.top.equalTo(bg).offset(36)
//            make.width.equalTo(40)
//        }
//
//        let questionLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: self.faq.question)
//        bg.addSubview(questionLabel)
//        questionLabel.snp.makeConstraints { make in
//            make.left.equalTo(questionDesLabel.snp.right).offset(10)
//            make.top.equalTo(questionDesLabel)
//            make.right.equalTo(bg).offset(-12)
//        }
//
//        let line = UIView.seperatorLine()
//        bg.addSubview(line)
//        line.snp.makeConstraints { make in
//            make.left.right.equalTo(bg)
//            make.height.equalTo(0.5)
//            make.top.equalTo(questionLabel.snp.bottom).offset(36)
//        }
//
//        bg.addSubview(ansDesLabel)
//        ansDesLabel.snp.makeConstraints { make in
//            make.top.equalTo(line).offset(12)
//            make.left.size.equalTo(questionDesLabel)
//        }
//
//        let ansLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: self.faq.answer)
//        ansLabel.numberOfLines = 0
//        bg.addSubview(ansLabel)
//        ansLabel.snp.makeConstraints { make in
//            make.left.equalTo(ansDesLabel.snp.right).offset(10)
//            make.top.equalTo(ansDesLabel)
//            make.right.equalTo(bg).offset(-12)
//        }
//    }
//}
