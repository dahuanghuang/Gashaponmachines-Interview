import RxCocoa
import RxSwift

extension Reactive where Base: SingleButtonBottomView {

    var buttonTap: ControlEvent<Void> {
        return self.base.button.rx.controlEvent(.touchUpInside)
    }
}

class SingleButtonBottomView: UIView {

    var button: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()

    init(title: String, titleColor: UIColor? = UIColor(hex: "754E00")!, backgroundColor: UIColor? = UIColor.new_yellow) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white

        self.addSubview(button)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(44)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
