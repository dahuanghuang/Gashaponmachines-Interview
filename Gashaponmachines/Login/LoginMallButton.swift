//import RxCocoa
//import RxSwift
//
//extension Reactive where Base: LoginMallButton {
//    var tap: ControlEvent<Void> {
//        return self.base.control.rx.controlEvent(.touchUpInside)
//    }
//}
//
//final class LoginMallButton: UIButton {
//
//    override var isEnabled: Bool {
//        didSet {
//            if isEnabled {
//                self.backgroundColor = .white
//            } else {
//                self.backgroundColor = .qu_lightGray
//            }
//        }
//    }
//
//    let control = UIControl(frame: .zero)
//
//    override init(frame: CGRect) {
//        super.init(frame: .zero)
//
//        let container = UIView()
//
//        self.addSubview(container)
//        container.snp.makeConstraints { make in
//            make.center.equalTo(self)
//            make.top.bottom.equalTo(self)
//        }
//
//        let icon = UIImageView(image: UIImage(named: "login_mall"))
//        container.addSubview(icon)
//        icon.snp.makeConstraints { make in
//            make.width.equalTo(35)
//            make.height.equalTo(30)
//            make.left.equalTo(container)
//            make.centerY.equalTo(container)
//        }
//
//        let titleLabel = UILabel.with(textColor: .qu_yellow, fontSize: 32, defaultText: "邮箱登录")
//        container.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.right.centerY.equalTo(container)
//            make.left.equalTo(icon.snp.right).offset(12)
//        }
//
//        self.layer.cornerRadius = 4
//        self.layer.borderColor = UIColor.qu_yellow.cgColor
//        self.layer.borderWidth = 1
//        self.addSubview(control)
//        control.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
