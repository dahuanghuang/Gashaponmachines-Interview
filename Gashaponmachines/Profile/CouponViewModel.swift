import RxSwift
import RxCocoa
import Argo
import Runes
import Curry

enum CouponType: String, CaseIterable {
//    case avaliable = "AVAIL"
//    case used = "USED"
//    case expired = "EXPIRED"
    case AVAIL
    case USED
    case EXPIRED

    var description: String {
        switch self {
        case .AVAIL:
            return "可使用"
        case .USED:
            return "已使用"
        case .EXPIRED:
            return "已过期"
        }
    }
}

class CouponViewModel: BaseViewModel {
    var requestCoupon = PublishSubject<Void>()
    var coupons = BehaviorRelay<[Coupon]>(value: [])

    init(couponType: CouponType) {
        super.init()

        let response = requestCoupon
            .flatMapLatest {
                AppEnvironment.current.apiService.getCouponsOfUser(type: couponType.rawValue).materialize()
            }
            .share(replay: 1)

        response.elements()
            .map { $0.coupons }
            .bind(to: coupons)
            .disposed(by: disposeBag)

        response.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}

public struct CouponEnvelope {
    var coupons: [Coupon]
}

public struct Coupon {
    // 优惠券id
    var couponId: String
    // 优惠券类型 DK蛋壳优惠券、YQ元气优惠券
    var type: String
    // 优惠券模式，只对DK优惠券有意义，ALL全场通用、PART指定商品可用
    var mode: String?
    // 使用条件
    var requirement: String
    // 扣减金额
    var amount: String
    // 优惠券标题
    var title: String?
    // 优惠券描述
    var desc: String?
    // 优惠券状态， 0、正常。1、即将过期。2、未生效。3、已使用。4、已过期
    var status: CouponStatus
    // 生效时间
    var validAt: String
    // 失效时间
    var invalidAt: String
    // 使用说明
    var notice: String?
    // 
    var canUse: String?
    // 不可使用原因
    var canUseNotice: String?
    //
    var action: String?
}

public enum CouponStatus: String {
    case normal = "0"       // 正常
    case willExpired = "1"  // 即将过期
    case notStared = "2"    // 未生效
    case userd = "3"        // 已使用
    case expired = "4"      // 已过期

    var image: String {
        switch self {
        case .normal: return "coupon_bg_normal"
        case .willExpired: return "coupon_bg_will_expired"
        case .notStared: return "coupon_bg_not_start"
        case .userd: return "coupon_bg_used"
        case .expired: return "coupon_bg_expired"
        }
    }
}

extension CouponEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<CouponEnvelope> {
        return curry(CouponEnvelope.init)
            <^> json <|| "coupons"
    }
}

extension Coupon: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<Coupon> {
        return curry(Coupon.init)
            <^> json <| "couponId"
            <*> json <| "type"
            <*> json <|? "mode"
            <*> json <| "requirement"
            <*> json <| "amount"
            <*> json <|? "title"
            <*> json <|? "desc"
            <*> json <| "status"
            <*> json <| "validAt"
            <*> json <| "invalidAt"
            <*> json <|? "notice"
            <*> json <|? "canUse"
            <*> json <|? "canUseNotice"
            <*> json <|? "action"

    }
}

extension CouponStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<CouponStatus> {
        switch json {
        case let .string(status):
            return pure(CouponStatus(rawValue: status) ?? .normal)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}
