import UIKit
import RxCocoa
import RxSwift

let PrivacyPoliciesKey = "PrivacyPoliciesKey"

enum PrivacyPoliciesViewType {
    case loginOrRegister
}

class LoginPrivacyView: UIView {

    var lookPrivacyHandle: (() -> Void)?

    private var disposeBag = DisposeBag()

    fileprivate var viewType: PrivacyPoliciesViewType

    lazy var checkIv: UIImageView = {
        let iv = UIImageView()
        let isSelect = UserDefaults.standard.bool(forKey: PrivacyPoliciesKey)
        let imageName = isSelect ? "login_selected" : "login_unselect"
        iv.image = UIImage(named: imageName)
        return iv
    }()

    lazy var checkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(checkButtonClick), for: .touchUpInside)
        let isSelect = UserDefaults.standard.bool(forKey: PrivacyPoliciesKey)
        button.isSelected = isSelect
        return button
    }()

    private lazy var textView: UITextView = {
        let view = UITextView(frame: CGRect.zero)
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.isEditable = false
        view.showsHorizontalScrollIndicator = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.delegate = self
        view.dataDetectorTypes = .link
        view.sizeToFit()
        return view
    }()

    private var text: String {
        switch viewType {
        case .loginOrRegister:
            return "登录表示同意 用户协议与隐私条约"
        }
    }

    private var range: NSRange? {
        let text = self.text as NSString
        switch viewType {
        case .loginOrRegister:
            return text.range(of: "用户协议与隐私条约")
        }
    }

    typealias URLMapping = (PrivacyPoliciesViewType, URL)

    fileprivate var url: URL {
        switch viewType {
        case .loginOrRegister:
            if let config = AppEnvironment.current.config, let agreementURL = config.siteURLs["userAgreementURL"] {
                return URL(string: agreementURL)!
            } else {
                return URL(string: "http://nd.quqqi.com/#/user-agreement")!
            }
        }
    }

    private var attributeFont: UIFont {
        switch viewType {
        case .loginOrRegister:
            return UIFont.withPixel(22)
        }
    }

    private var attributeForegroundColor: UIColor {
        switch viewType {
        case .loginOrRegister:
            return UIColor.qu_lightGray
        }
    }

    private var foregroundColor: UIColor {
        switch viewType {
        case .loginOrRegister:
            return .qu_blue
        }
    }

    private var linkTextAttributes: [NSAttributedString.Key: Any] {
        switch viewType {
        case .loginOrRegister:
            return [NSAttributedString.Key.foregroundColor: UIColor.qu_blue]
        }
    }

    init(viewType: PrivacyPoliciesViewType) {
        self.viewType = viewType
        super.init(frame: CGRect.zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {

        // 默认选中
        UserDefaults.standard.setValue(true, forKey: PrivacyPoliciesKey)
        UserDefaults.standard.synchronize()

        // 提示文字
        self.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        let string = NSMutableAttributedString(string: self.text, attributes: [NSAttributedString.Key.font: self.attributeFont, NSAttributedString.Key.foregroundColor: self.attributeForegroundColor])

        string.beginEditing()
        if let range = self.range {
            string.addAttributes([NSAttributedString.Key.link: url], range: range)
        }
        string.endEditing()
        self.textView.attributedText = string
        self.textView.linkTextAttributes = self.linkTextAttributes

        // 选中图片
        self.addSubview(checkIv)
        checkIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(textView.snp.left).offset(-5)
            make.size.equalTo(15)
        }

        // 选中按钮
//        checkButton.backgroundColor = .black
        self.addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.left.height.centerY.equalToSuperview()
            make.right.equalTo(textView.snp.left).offset(40)
        }
    }

    @objc func checkButtonClick() {
        checkButton.isSelected = !checkButton.isSelected
        let imageName = checkButton.isSelected ? "login_selected" : "login_unselect"
        checkIv.image = UIImage(named: imageName)
        UserDefaults.standard.setValue(checkButton.isSelected, forKey: PrivacyPoliciesKey)
        UserDefaults.standard.synchronize()
    }

    deinit {
        self.disposeBag = DisposeBag()
    }
}

extension LoginPrivacyView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let handle = lookPrivacyHandle {
            handle()
        }
        return false
    }
}
