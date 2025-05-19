import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: ExchangeBottomView {
    var totalCount: Binder<Int> {
        return Binder(self.base) { (view, count) -> Void in
            view.countLabel.text = "\(count)"
        }
    }

    var exchangeTap: ControlEvent<Void> {
        return self.base.exchangeButton.rx.controlEvent(.touchUpInside)
    }
    
    var isExchangeButtonEnable: Binder<Bool> {
        return Binder(self.base) { (view, isEnable) -> Void in
            if isEnable {
                view.exchangeView.backgroundColor = UIColor(hex: "FFDA60")
                view.exchangeButton.layer.borderColor = UIColor.new_yellow.cgColor
            }else {
                view.exchangeView.backgroundColor = .new_backgroundColor
                view.exchangeButton.layer.borderColor = UIColor(hex: "D2D2D2")!.alpha(0.2).cgColor
            }
        }
    }
}

class ExchangeBottomView: UIView {
    
    lazy var countLabel: UILabel = {
        let lb = UILabel.numberFont(size: 28, defaultText: "0")
        lb.textColor = .new_orange
        return lb
    }()
    /// 黄色背景视图
    let exchangeView = UIView.withBackgounrdColor(UIColor(hex: "FFDA60")!)
    /// 确认按钮
    lazy var exchangeButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.new_yellow.cgColor
        btn.setTitle("批量换取", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setBackgroundColor(color: .white.alpha(0.2), forUIControlState: .normal)
        btn.setTitleColor(UIColor(hex: "754E00")!, for: .normal)
        btn.setBackgroundColor(color: .new_backgroundColor.alpha(0.2), forUIControlState: .disabled)
        btn.setTitleColor(UIColor(hex: "A6A6A6")!, for: .disabled)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        let container = UIView()
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        exchangeView.layer.cornerRadius = 8
        container.addSubview(exchangeView)
        exchangeView.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(44)
        }

        exchangeView.addSubview(exchangeButton)
        exchangeButton.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.bottom.equalTo(-4)
        }
        
        let dankeLabel = UILabel.with(textColor: .qu_black, boldFontSize: 24, defaultText: "蛋壳")
        container.addSubview(dankeLabel)
        dankeLabel.snp.makeConstraints { make in
            make.right.equalTo(exchangeView.snp.left).offset(-8)
            make.centerY.equalTo(exchangeView)
        }
        
        container.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.right.equalTo(dankeLabel.snp.left).offset(-2)
            make.bottom.equalTo(dankeLabel).offset(8)
        }

        let exchangeLabel = UILabel.with(textColor: .qu_black, boldFontSize: 24, defaultText: "共换取:")
        container.addSubview(exchangeLabel)
        exchangeLabel.snp.makeConstraints { make in
            make.right.equalTo(countLabel.snp.left).offset(-2)
            make.centerY.equalTo(dankeLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
