import UIKit
import RxCocoa
import RxSwift

enum ProfileImageTitleButtonType {
    case recharge
    case exchange
    case unknown
}

extension Reactive where Base: ProfileImageTitleButton {
    var tap: ControlEvent<Void> {
        return self.base.rx.controlEvent(.touchUpInside)
    }
}

class ProfileImageTitleButton: UIButton {

    let titleLbl = UILabel.with(textColor: .qu_black, fontSize: 20)

    lazy var valueLabel: UILabel = {
        let lb = UILabel.numberFont(size: 20)
        lb.textColor = .black
        return lb
    }()

    let icon = UIImageView()

    var type: ProfileImageTitleButtonType = .unknown

    var title: String {
        switch type {
        case .recharge:
            return "去充值"
        case .exchange:
            return "去兑换"
        default:
            return ""
        }
    }

    var image: UIImage? {
        switch type {
        case .recharge:
            return UIImage(named: "profile_recharge")
        case .exchange:
            return UIImage(named: "profile_exchange")
        default:
            return nil
        }
    }

    var value: String = "0" {
        didSet {
            switch type {
            case .recharge:
                self.valueLabel.text = "\(value)"
            case .exchange:
                self.valueLabel.text = "\(value)"
            default:
                break
            }
        }
    }

    init(type: ProfileImageTitleButtonType) {
        self.type = type
        super.init(frame: .zero)

        self.backgroundColor = .white

        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        self.addSubview(icon)
        icon.image = image
        icon.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.right.equalTo(-10)
            make.size.equalTo(62)
        }

        self.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(12)
        }
        
        let text = (type == .recharge ? "元气" : "蛋壳")
        let yuanqiLb = UILabel.with(textColor: .black, fontSize: 20, defaultText: text)
        self.addSubview(yuanqiLb)
        yuanqiLb.snp.makeConstraints { make in
            make.left.equalTo(valueLabel.snp.right).offset(2)
            make.bottom.equalTo(valueLabel).offset(-6)
        }

        self.addSubview(titleLbl)
        titleLbl.text = title
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(-24)
        }

        let arrowIv = UIImageView(image: UIImage(named: "profile_arrow"))
        self.addSubview(arrowIv)
        arrowIv.snp.makeConstraints { make in
            make.left.equalTo(titleLbl.snp.right).offset(2)
            make.centerY.equalTo(titleLbl)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// class ProfileImageTitleButton: UIButton {
//
//    let icon = UIImageView()
//
//    let titleLbl = UILabel.with(textColor: UIColor.qu_black, fontSize: 32)
//
//    let subTitleLabel = UILabel.with(textColor: UIColor.qu_lightGray, fontSize: 20)
//
//    var type: ProfileImageTitleButtonType = .unknown
//
//    var title: String {
//        switch type {
//        case .recharge:
//            return "\(AppEnvironment.reviewKeyWord)充值"
//        case .exchange:
//            return "蛋壳商城"
//        case .coupon:
//            return "优惠券"
//        default:
//            return ""
//        }
//    }
//
//    var image: UIImage? {
//        switch type {
//        case .recharge:
//            return UIImage(named: "profile_recharge")
//        case .exchange:
//            return UIImage(named: "profile_exchange")
//        case .coupon:
//            return UIImage(named: "profile_exchange")
//        default:
//            return nil
//        }
//    }
//
//    var value: String = "0" {
//        didSet {
//            switch type {
//            case .recharge:
//                self.subTitleLabel.text = "元气 \(value)"
//            case .exchange:
//                self.subTitleLabel.text = "蛋壳 \(value)"
//            case .coupon:
//                self.subTitleLabel.text = "\(value)"
//            default:
//                break
//            }
//        }
//    }
//
//    init(type: ProfileImageTitleButtonType) {
//        self.type = type
//        super.init(frame: .zero)
//
//        self.addSubview(icon)
//        icon.image = image
//        icon.snp.makeConstraints { make in
//            make.size.equalTo(50)
//            make.top.centerX.equalTo(self)
//        }
//
//        self.addSubview(titleLbl)
//        titleLbl.text = title
//        titleLbl.snp.makeConstraints { make in
//            make.top.equalTo(icon.snp.bottom).offset(4)
//            make.centerX.equalTo(self)
//        }
//
//        self.addSubview(subTitleLabel)
//        subTitleLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLbl.snp.bottom).offset(4)
//            make.bottom.centerX.equalTo(self)
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
// }
