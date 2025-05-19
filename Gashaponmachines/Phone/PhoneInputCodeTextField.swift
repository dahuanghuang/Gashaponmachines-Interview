import UIKit
import RxSwift
import RxCocoa

open class PhoneInputCodeTextField: UIView, UIKeyInput {
    static let totalWidth = 48 * 4 + 12 * 3
    private let NumberOfBit = 4

    private var nextTag = 0

    // MARK: - UIResponder
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    var completionClosure: ((String) -> Void)?

    var codeArray: [Character] = []

    // MARK: - UIView
    public override init(frame: CGRect) {
        super.init(frame: frame)

        // Add 7 digitLabels

        for index in 0...NumberOfBit-1 {

            let bottom = UIImageView(image: UIImage(named: "phone_tf_bottom")?.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)))

            addSubview(bottom)
            bottom.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 48, height: 3))
                make.left.equalToSuperview().offset((48 + 12) * index)
                make.bottom.equalToSuperview()
            }

            let label = UILabel.with(textColor: .qu_black, boldFontSize: 56)
            label.textAlignment = .center
            label.tag = index+9000
            addSubview(label)
            label.snp.makeConstraints { make in
                make.bottom.equalTo(bottom.snp.top).offset(-12)
                make.centerX.equalTo(bottom)
                make.top.equalToSuperview()
                make.size.equalTo(UIFont.withBoldPixel(56).lineHeight)
            }

        }
    }

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") } // NSCoding
    // MARK: - UIKeyInput
    public var hasText: Bool {
        return nextTag > 0 ? true : false
    }

    open func insertText(_ text: String) {
        if nextTag < NumberOfBit {
            let label = viewWithTag(nextTag+9000) as! UILabel
            label.text = text

            if codeArray.count < nextTag+1 {
                codeArray.append(Character(text))
            }

            nextTag += 1
            if nextTag == NumberOfBit, let block = completionClosure {
                block(String(codeArray))
            }
        }
    }

    open func deleteBackward() {
        if nextTag > 0 {
            nextTag -= 1
            let label = viewWithTag(nextTag+9000) as! UILabel
            label.text = nil
        }
    }

    open func clear() {
        while nextTag > 0 {
            deleteBackward()
        }
    }

    // MARK: - UITextInputTraits
    open var keyboardType: UIKeyboardType {
        get { return .phonePad }
        set {}
    }
}
