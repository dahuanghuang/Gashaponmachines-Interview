//import UIKit
//import RxCocoa
//import RxSwift
//
//extension Reactive where Base: LoginWechatButton {
//    var tap: ControlEvent<Void> {
//        return self.base.control.rx.controlEvent(.touchUpInside)
//    }
//}
//
//final class LoginWechatButton: UIButton {
//
////    override var isEnabled: Bool {
////        didSet {
////            if isEnabled {
////                self.backgroundColor = .qu_green
////            } else {
////                self.backgroundColor = .qu_lightGray
////            }
////        }
////    }
//
//    let control = UIControl(frame: .zero)
//
//    override init(frame: CGRect) {
//        super.init(frame: .zero)
//
//        self.backgroundColor = .qu_green
//
//        let container = UIView()
//        self.addSubview(container)
//        container.snp.makeConstraints { make in
//            make.center.equalTo(self)
//            make.top.bottom.equalTo(self)
//        }
//
//        let icon = UIImageView(image: UIImage(named: "login_wechat"))
//        container.addSubview(icon)
//        icon.snp.makeConstraints { make in
//            make.width.equalTo(35)
//            make.height.equalTo(30)
//            make.left.equalTo(container)
//            make.centerY.equalTo(container)
//        }
//
//        let titleLabel = UILabel.with(textColor: .white, fontSize: 32, defaultText: "微信登录")
//		container.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.right.centerY.equalTo(container)
//            make.left.equalTo(icon.snp.right).offset(12)
//        }
//
//        self.layer.cornerRadius = 4
//
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
