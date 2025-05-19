import RxCocoa
import RxSwift
import RxKeyboard

class PhoneBindingView: UIView {

    lazy var iv = UIImageView.with(imageName: "phone_rebind")

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "绑定手机可获得")

    lazy var bindButton: UIButton = {
        let b = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "下一步", fontSize: 28)
        b.setBackgroundColor(color: .viewBackgroundColor, forUIControlState: .disabled)
        b.setBackgroundColor(color: .qu_yellow, forUIControlState: .normal)
        b.setTitleColor(.qu_black, for: .normal)
        b.setTitleColor(.qu_lightGray, for: .disabled)
        return b
    }()

    lazy var contentView = RoundedCornerView(corners: .allCorners, radius: 4)

    lazy var inputCodeView: UITextField = {
        let v = UITextField()
        v.textColor = .black
        v.font = UIFont.withBoldPixel(28)
        v.attributedPlaceholder = NSAttributedString(string: "请输入手机号码", attributes: [NSAttributedString.Key.foregroundColor: UIColor.qu_lightGray])
        v.textAlignment = .center
        v.layer.cornerRadius = 4
        v.delegate = self
        v.layer.borderColor = UIColor.qu_yellow.cgColor
        v.layer.borderWidth = 1
        v.keyboardType = .phonePad
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(50)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        let lists: [(String, String)] = [
            ("phone_rebind_1", "机台维护信息"),
            ("phone_rebind_2", "兑换商城新货提醒"),
            ("phone_rebind_3", "发货第一时间知道"),
            ("phone_rebind_4", "最新活动")
            ]

        var lastView: UIView = titleLabel

        lists.forEach { list in

            let logo = UIImageView.with(imageName: list.0)
            addSubview(logo)
            logo.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(lastView == titleLabel ? 20 : 12)
                make.size.equalTo(16)
                make.left.equalTo(titleLabel).offset(-8)
            }

            let label = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: list.1)
            label.textAlignment = .left
            addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(logo.snp.right).offset(8)
                make.centerY.equalTo(logo)
            }

            lastView = logo
        }

        addSubview(inputCodeView)
        inputCodeView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(36)
            make.height.equalTo(48)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }

        addSubview(bindButton)
        bindButton.snp.makeConstraints { make in
            make.top.equalTo(inputCodeView.snp.bottom).offset(16)
            make.left.right.height.equalTo(inputCodeView)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    @objc func endKeyboardEditing() {
        endEditing(true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhoneBindingView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let str = textField.text?.replacingOccurrences(of: " ", with: "")

        textField.text = str

        return true
    }
}
