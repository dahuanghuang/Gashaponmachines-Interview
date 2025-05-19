import RxSwift
import RxGesture
import RxCocoa

extension Reactive where Base: PhoneInputCodeView {

    var phone: Binder<String> {
        return Binder(self.base) { (view, phone) -> Void in
            view.phoneLabel.text = "你的手机号 \(phone)"
        }
    }
}

/// 输入验证码视图
class PhoneInputCodeView: DimBackgroundView {

    lazy var iv = UIImageView.with(imageName: "phone_input_code")

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "请输入验证码")

    lazy var inputCodeTextField = PhoneInputCodeTextField()

    lazy var timerButton = UIButton.with(title: nil, titleColor: .qu_lightGray, fontSize: 24)

    lazy var backButton = UIButton.with(imageName: "phone_back")

    lazy var phoneLabel: UILabel = {
        let l = UILabel.with(textColor: .qu_black, fontSize: 24)
        l.textAlignment = .center
        return l
    }()

    lazy var desLabel2: UILabel = {
        let l = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "会收到一条带验证码的短信")
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.backgroundColor = .white

        addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(50)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.top.left.equalToSuperview().offset(8)
        }

        addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(44)
            make.centerX.equalToSuperview()
        }

        addSubview(desLabel2)
        desLabel2.snp.makeConstraints { make in
            make.top.equalTo(phoneLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }

        addSubview(inputCodeTextField)
        inputCodeTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(becomeResponder)))
        inputCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(desLabel2.snp.bottom).offset(68)
            make.centerX.equalToSuperview()
            make.width.equalTo(PhoneInputCodeTextField.totalWidth)
        }

        addSubview(timerButton)
        timerButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-36)
            make.centerX.equalToSuperview()
            make.top.equalTo(inputCodeTextField.snp.bottom).offset(36)
        }
    }

    @objc func becomeResponder() {
        self.inputCodeTextField.becomeFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
