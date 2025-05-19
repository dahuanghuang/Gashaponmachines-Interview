import UIKit

protocol RechargeFromFooterViewDelegate: class {
    func didSelectedMethod(method: PaymentMethod)
}

class RechargeFromFooterView: UIView {

    weak var delegate: RechargeFromFooterViewDelegate?

    var methods = [PaymentMethod]()

    var buttons = [RechargeFromButton]()

    init(delegate: RechargeFromFooterViewDelegate?) {
        super.init(frame: .zero)

        self.isUserInteractionEnabled = true
        self.delegate = delegate
        self.backgroundColor = .clear
    }

    func updatePaymentButton(methods: [PaymentMethod]) {

        self.methods = methods
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll()

        for (index, method) in methods.enumerated() {
            let button = RechargeFromButton(method: method)
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            self.addSubview(button)
            buttons.append(button)

            button.snp.makeConstraints { make in
                make.height.equalTo(42)
                make.left.equalTo(12)
                make.right.equalTo(-12)

                if index == 0 {
                    make.top.equalToSuperview()
                } else if index == 1 {
                    make.bottom.equalToSuperview()
                }
            }

            if method.selected {
                self.buttonTapped(button: button)
            }
        }
    }

    @objc func buttonTapped(button: RechargeFromButton) {

        buttons.forEach { button in
            button.isSelected = false
        }
        button.isSelected = true

        self.delegate?.didSelectedMethod(method: button.method)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
