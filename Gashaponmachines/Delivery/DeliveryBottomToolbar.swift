import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: DeliveryBottomToolbar {
    var selectAllButtonTap: ControlEvent<Void> {
        return self.base.selectedAllIcon.rx.controlEvent(.touchUpInside)
    }

    var isSelectedAll: Binder<Bool> {
        return Binder(self.base) { (view, isSelectedAll) -> Void in
            view.selectedAllIcon.isSelected = isSelectedAll
        }
    }
    
    var isNextButtonEnable: Binder<Bool> {
        return Binder(self.base) { (view, isEnable) -> Void in
            if isEnable {
                view.nextView.backgroundColor = UIColor(hex: "FFDA60")
                view.nextButton.layer.borderColor = UIColor.new_yellow.cgColor
            }else {
                view.nextView.backgroundColor = .new_backgroundColor
                view.nextButton.layer.borderColor = UIColor(hex: "D2D2D2")!.alpha(0.2).cgColor
            }
        }
    }

    var nextButtonTap: ControlEvent<Void> {
        return self.base.nextButton.rx.controlEvent(.touchUpInside)
    }

    var money: Binder<Int> {
        return Binder(self.base) { (view, money) -> Void in
            view.valueLabel.text = "价值 \(money) 蛋壳"
        }
    }

    var itemCount: Binder<Int> {
        return Binder(self.base) { (view, count) -> Void in
            let totalStr = "共 \(count) 件"
            let string = NSMutableAttributedString(string: totalStr, attributes: [
                NSAttributedString.Key.font: UIFont.withBoldPixel(32),
                NSAttributedString.Key.foregroundColor: UIColor.qu_black
                ])
            let range = totalStr.range(of: "\(count)")!
            let nsRange = NSRange(range, in: totalStr)
            string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.qu_orange], range: nsRange)
            view.countLabel.attributedText = string
        }
    }
}

enum DeliveryBottomToolbarStyle {
    case start 				// 蛋壳 开始确认地址
    case eggProductConfirm  // 蛋壳 确认发货
    case mallProductConfirm // 兑换商品 确认发货
}

class DeliveryBottomToolbar: UIView {

    var buttonTitle: String {
        switch style {
        case .start:
            return "下一步"
        case .eggProductConfirm, .mallProductConfirm:
            return "确定"
        }
    }

    lazy var selectedAllIcon: UIButton = {
           let button = UIButton.with(imageName: "login_unselect")
        button.setImage(UIImage(named: "login_unselect"), for: .normal)
        button.setImage(UIImage(named: "login_selected"), for: .selected)
        return button
    }()
    
    let contentView = UIView.withBackgounrdColor(.clear)
    
    /// 黄色背景视图
    let nextView = UIView.withBackgounrdColor(UIColor(hex: "FFDA60")!)
    /// 确认按钮
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.new_yellow.cgColor
        btn.setTitle(buttonTitle, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.setBackgroundColor(color: .white.alpha(0.2), forUIControlState: .normal)
        btn.setTitleColor(UIColor(hex: "754E00")!, for: .normal)
        btn.setBackgroundColor(color: .new_backgroundColor.alpha(0.2), forUIControlState: .disabled)
        btn.setTitleColor(UIColor(hex: "A6A6A6")!, for: .disabled)
        return btn
    }()

    lazy var countLabel = UILabel.with(textColor: UIColor.qu_black, fontSize: 32, defaultText: "共 0 件")

    lazy var valueLabel = UILabel.with(textColor: UIColor.qu_black, fontSize: 20, defaultText: "价值 0 蛋壳")

    lazy var expressFeeLabel = UILabel.with(textColor: UIColor.qu_black, fontSize: 32)

    lazy var couponLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 24)

    fileprivate var style: DeliveryBottomToolbarStyle

    init(style: DeliveryBottomToolbarStyle) {
        self.style = style
        super.init(frame: .zero)

        self.backgroundColor = .white
        
        
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }

        nextView.layer.cornerRadius = 8
        contentView.addSubview(nextView)
        nextView.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(176)
            make.height.equalTo(44)
        }

        nextView.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.bottom.equalTo(-4)
        }

        if style == .start {
            contentView.addSubview(selectedAllIcon)
            selectedAllIcon.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(12)
                make.centerY.equalToSuperview()
                make.size.equalTo(30)
            }

            let selectedAllLabel = UILabel.with(textColor: .qu_black, fontSize: 32, defaultText: "全选")
            contentView.addSubview(selectedAllLabel)
            selectedAllLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(selectedAllIcon.snp.right).offset(8)
            }

            contentView.addSubview(countLabel)
            countLabel.snp.makeConstraints { make in
                make.bottom.equalTo(contentView.snp.centerY)
                make.right.equalTo(nextView.snp.left).offset(-12)
            }
            
            contentView.addSubview(valueLabel)
            valueLabel.snp.makeConstraints { make in
                make.top.equalTo(countLabel.snp.bottom).offset(4)
                make.right.equalTo(countLabel)
            }
        } else if style == .eggProductConfirm || style == .mallProductConfirm {
            contentView.addSubview(expressFeeLabel)
            expressFeeLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(nextView.snp.left).offset(-12)
            }

            contentView.addSubview(couponLabel)
            couponLabel.snp.makeConstraints { make in
                make.top.equalTo(expressFeeLabel.snp.bottom).offset(4)
                make.right.equalTo(expressFeeLabel)
            }
        }
    }

    func config(style: ConfirmDeliveryStyle, value: Int, coupon: Coupon?) {

        let typeStr = (style == .mallProduct ? "蛋壳" : "元气")

        var valueStr = "\(value)"
        if let selectCoupon = coupon, let amount = Int(selectCoupon.amount) {
            self.couponLabel.text = "已优惠\(amount)\(typeStr)"
            valueStr = "\(value - amount)"
            
            expressFeeLabel.snp.remakeConstraints { make in
                make.bottom.equalTo(contentView.snp.centerY)
                make.right.equalTo(nextView.snp.left).offset(-12)
            }
        } else {
            self.couponLabel.text = ""
            
            expressFeeLabel.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(nextView.snp.left).offset(-12)
            }
        }

        let totalStr = "需消耗："
        let string = NSMutableAttributedString(string: totalStr, attributes: [
            NSAttributedString.Key.font: UIFont.withBoldPixel(32),
            NSAttributedString.Key.foregroundColor: UIColor.qu_black
            ])
        let countStr = NSAttributedString.init(string: valueStr, attributes: [
            NSAttributedString.Key.font: UIFont.withBoldPixel(32),
            NSAttributedString.Key.foregroundColor: UIColor.new_discountColor
            ])
        let eggshellStr = NSAttributedString.init(string: typeStr, attributes: [
            NSAttributedString.Key.font: UIFont.withBoldPixel(32),
            NSAttributedString.Key.foregroundColor: UIColor.qu_black
            ])
        string.append(countStr)
        string.append(eggshellStr)
        self.expressFeeLabel.attributedText = string
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
