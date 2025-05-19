import UIKit

class OccupyRechargeFromFooterView: UIView {

    weak var delegate: RechargeFromFooterViewDelegate?

    var methods: [PaymentMethod] = []

    var buttons: [OccupyRechargeFromButton] = []

    init(methods: [PaymentMethod], delegate: RechargeFromFooterViewDelegate?) {
        super.init(frame: .zero)

        self.isUserInteractionEnabled = true
        self.delegate = delegate
        self.methods = methods
        self.backgroundColor = .clear

        let contentView = UIView.withBackgounrdColor(.clear)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(-8)
        }
        
        let line = UIView.withBackgounrdColor(.new_backgroundColor.alpha(0.4))
        line.isHidden = (methods.count == 1)
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(1)
        }

        for (index, method) in methods.enumerated() {
            let button = OccupyRechargeFromButton(method: method)
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            contentView.addSubview(button)
            buttons.append(button)
            

            button.snp.makeConstraints { make in
                make.height.equalTo(44)
                make.left.right.equalToSuperview()
                if index == 0 {
                    make.top.equalToSuperview()
                } else {
                    make.bottom.equalToSuperview()
                }
            }

            if method.selected {
                self.buttonTapped(button: button)
            }
        }
    }

    @objc func buttonTapped(button: OccupyRechargeFromButton) {

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

class OccupyRechargeFromButton: UIButton {

    let icon = UIImageView()
    let selectedIcon = UIImageView()
    let titleLbl = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    let subTitleLabel = UILabel.with(textColor: .new_brown, fontSize: 24)

    var method: PaymentMethod

    init(method: PaymentMethod) {
        self.method = method
        super.init(frame: .zero)

        self.isUserInteractionEnabled = true
        
        self.addSubview(icon)
        self.addSubview(selectedIcon)
        self.addSubview(titleLbl)
        self.addSubview(subTitleLabel)

        selectedIcon.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.right.equalTo(self).offset(-12)
            make.centerY.equalTo(self)
        }

        icon.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.left.equalTo(12)
            make.centerY.equalTo(self)
        }

        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(8)
            make.centerY.equalTo(self)
        }

        subTitleLabel.textAlignment = .right
        subTitleLabel.snp.makeConstraints { make in
            make.right.equalTo(selectedIcon.snp.left).offset(-12)
            make.centerY.equalTo(self)
        }

        self.icon.gas_setImageWithURL(method.icon)
        self.titleLbl.text = method.title
        self.subTitleLabel.text = method.subTitle
        self.selectedIcon.image = UIImage(named: "occupy_recharge_unselect")
    }

    override var isSelected: Bool {
        didSet {
            self.selectedIcon.image = isSelected ?  UIImage(named: "occupy_recharge_select") : UIImage(named: "occupy_recharge_unselect")
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
