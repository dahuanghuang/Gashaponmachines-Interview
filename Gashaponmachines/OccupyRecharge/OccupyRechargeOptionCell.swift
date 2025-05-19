import RxCocoa

let OccupyRechargeOptionCellButtonHeight: CGFloat = 103
let OccupyRechargeOptionCellBottomPadding: CGFloat = 37 / 2
// cell宽度
let OccupyRechargeCellW: CGFloat = (Constants.kScreenWidth - 44) / 3

protocol OccupyRechargeOptionCellDelegate: class {
    func didSelectedPaymentOption(amount: Double)
}

class OccupyRechargeOptionCell: BaseTableViewCell {

    var buttons: [OccupyRechargeOptionButton] = []
    var options: [PaymentOption] = []

    weak var delegate: OccupyRechargeOptionCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(options: [PaymentOption], delegate: OccupyRechargeOptionCellDelegate?) {
        self.delegate = delegate

        for (index, option) in options.enumerated() {
            var frame: CGRect = .zero
            if index == 0 {
                frame = CGRect(x: 12, y: 12, width: OccupyRechargeCellW, height: OccupyRechargeOptionCellButtonHeight)
            } else if index == 1 {
                frame = CGRect(x: 22 + OccupyRechargeCellW, y: 12, width: OccupyRechargeCellW, height: OccupyRechargeOptionCellButtonHeight)
            } else if index == 2 {
                frame = CGRect(x: 32 + OccupyRechargeCellW * 2, y: 12, width: OccupyRechargeCellW, height: OccupyRechargeOptionCellButtonHeight)
            }

            let button = OccupyRechargeOptionButton(frame: frame, option: option)
            button.fakeButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
            contentView.addSubview(button)
            buttons.append(button)

            if option.selected {
                buttonTap(button: button.fakeButton)
            }
        }
    }

    @objc func buttonTap(button: PassableUIButton) {
        buttons.forEach { btn in
            btn.isSelected = false
        }
        if let superview = button.superview as? OccupyRechargeOptionButton {
            superview.isSelected = true
        }

        if let amountParam = button.params["amount"] as? String, let amount = Double(amountParam) {
            self.delegate?.didSelectedPaymentOption(amount: amount)
        } else {
            HUD.showError(second: 2, text: "无效的金额参数", completion: nil)
        }
    }
}
