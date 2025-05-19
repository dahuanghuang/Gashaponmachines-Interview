import UIKit

protocol RechargeOptionCellDelegate: class {
    func didSelectedPaymentOption(paymentPlan: PaymentPlan)
}

class RechargeOptionCell: BaseTableViewCell {

    weak var delegate: RechargeOptionCellDelegate?

    var buttons: [RechargeOptionButton] = []

    var paymentPlans: [PaymentPlan] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.isUserInteractionEnabled = true

        self.backgroundColor = .white
    }

    func configureWith(balance: String, paymentPlans: [PaymentPlan], delegate: RechargeOptionCellDelegate?) {

        buttons.removeAll()

        self.delegate = delegate
        self.paymentPlans = paymentPlans

        let row = ceil(CGFloat(paymentPlans.count/2))
        let optionViewH = 20 + row * (RechargeHeaderViewOptionButtonHeight + 12)
        let optionView = UIView()
        optionView.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: optionViewH)
        optionView.backgroundColor = .clear
        self.contentView.addSubview(optionView)

        for (index, paymentPlan) in paymentPlans.enumerated() {
            // FIXME 无法选中的问题，现在暂时用一个假的button
            let row = CGFloat(index / 2)
            let col = CGFloat(index % 2)
            let x: CGFloat = 12 + col * (RechargeHeaderViewOptionButtonWidth + 12)
            let y: CGFloat = 16 + row * (RechargeHeaderViewOptionButtonHeight + 12)
            let frame = CGRect(x: x, y: y, width: RechargeHeaderViewOptionButtonWidth, height: RechargeHeaderViewOptionButtonHeight)

            let button = RechargeOptionButton(frame: frame, paymentPlan: paymentPlan)
            button.fakeButton.tag = index
            button.fakeButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
            optionView.addSubview(button)
            buttons.append(button)

            if paymentPlan.selected {
                buttonTap(button: button.fakeButton)
            }
        }
    }

    // 选择 action
    @objc func buttonTap(button: PassableUIButton) {
        buttons.forEach { btn in
            btn.isSelected = false
        }
        if let superview = button.superview as? RechargeOptionButton {
            superview.isSelected = true
        }

        self.delegate?.didSelectedPaymentOption(paymentPlan: self.paymentPlans[button.tag])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
