import RxCocoa
import RxSwift

extension Reactive where Base: CompositionDetailTableFooterView {

    var description: Binder<String> {
        return Binder(self.base) { (view, description) -> Void in
            view.label.text = description
            view.label.setLineSpacing(lineHeightMultiple: 1.5)
        }
    }
}

class CompositionDetailTableFooterView: UIView {

    lazy var label = UILabel.with(textColor: .qu_black, fontSize: 24)

    init(text: String?) {
        super.init(frame: .zero)

        self.backgroundColor = UIColor(hex: "ffe6ac")

        let container = UIView.withBackgounrdColor(UIColor(hex: "fdf7df")!)
        container.layer.cornerRadius = 8
        container.layer.masksToBounds = true
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }

        container.addSubview(label)
        label.text = text
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = Constants.kScreenWidth - 56
        label.textAlignment = .left
        label.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
            make.bottom.right.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
