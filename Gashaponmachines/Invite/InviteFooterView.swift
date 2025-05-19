import RxCocoa
import RxSwift

extension Reactive where Base: InviteFooterView {
    var rules: Binder<String> {
        return Binder(self.base) { (view, rules) -> Void in
            view.label.text = rules
            view.label.setLineSpacing(lineHeightMultiple: 1.5)
        }
    }
}

class InviteFooterView: UIView {

    let label = UILabel.with(textColor: UIColor.UIColorFromRGB(0xb67518), fontSize: 24)

    override init(frame: CGRect) {
        super.init(frame: frame)

        let roundedView = RoundedCornerView(corners: [.bottomLeft, .bottomRight], radius: 4)
        self.addSubview(roundedView)
        roundedView.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.left.equalTo(self).offset(8)
            make.right.equalTo(self).offset(-8)
            make.top.equalTo(self)
        }

        self.backgroundColor = .qu_yellow
        label.preferredMaxLayoutWidth = Constants.kScreenWidth - 40 - 16
        label.numberOfLines = 0
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(roundedView.snp.bottom).offset(16)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
        }

        let iv = UIImageView(image: UIImage(named: "invite_bottom_bg"))
        self.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
