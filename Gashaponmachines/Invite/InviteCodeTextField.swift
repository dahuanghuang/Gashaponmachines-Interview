import UIKit
import RxSwift
import RxCocoa

let NumberOfBit = 7

open class InviteCodeTextField: UIView, UIKeyInput {
    open weak var delegate: CodeInputViewDelegate?
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
            let digitLabel = UIImageView(frame: frame)
            digitLabel.image = UIImage(named: "input_empty")
            digitLabel.tag = index+9000
            digitLabel.frame = CGRect(x: CGFloat((30 + 5) * index), y: 0, width: 30, height: 45)
            addSubview(digitLabel)
        }
    }

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") } // NSCoding
    // MARK: - UIKeyInput
    public var hasText: Bool {
        return nextTag > 0 ? true : false
    }

    open func insertText(_ text: String) {
        if nextTag < NumberOfBit {
            let iv = viewWithTag(nextTag+9000) as! UIImageView
            iv.image = UIImage(named: "input_\(text)")
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
            let iv = viewWithTag(nextTag+9000) as! UIImageView
            iv.image = UIImage(named: "input_empty")
        }
    }

    open func clear() {
        while nextTag > 0 {
            deleteBackward()
        }
    }

    // MARK: - UITextInputTraits
    open var keyboardType: UIKeyboardType {
        get { return .numberPad }
        set {}
    }
}

public protocol CodeInputViewDelegate: class {
    func codeInputView(_ codeInputView: InviteCodeTextField, didFinishWithCode code: String)
}
