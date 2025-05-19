var CONST_PROFILES: [[Profile]] {
    return [
        [.toBeDelivered, .delivered, .received],
        [.gameRecord, .onePieceTaskRecord, .exchangeRecord, .rechargeRecord]
    ]
}

public enum Profile: String {
    case toBeDelivered      = "未发货"
    case delivered          = "已发货"
    case received           = "已完成"

    case gameRecord         = "扭蛋记录"
    case onePieceTaskRecord = "元气赏记录"
    case exchangeRecord     = "蛋壳记录"
    case rechargeRecord     = "元气记录"

//    case faq                = "客服留言"
//    case invite             = "邀请好友"
//    case myGift             = "兑换码"
//    case coupon             = "优惠券"
//    case address            = "我的地址"
//    case uploadEvent        = "日志上报"
//    case switchEnv          = "切换环境"

    var iconImageName: String {
        switch self {
        case .toBeDelivered:        return "profile_toBeDelivered"
        case .delivered:            return "profile_delivered"
        case .received:             return "profile_received"

        case .gameRecord:           return "profile_gameRecord"
        case .onePieceTaskRecord:   return "profile_yfsRecord"
        case .exchangeRecord:       return "profile_mallRecord"
        case .rechargeRecord:       return "profile_rechargeRecord"

//        case .faq:                  return "profile_faq"
//        case .invite:               return "profile_invite"
//        case .myGift:               return "profile_gift"
//        case .coupon:               return "profile_coupon"
//        case .address:              return "profile_address"
//        case .uploadEvent:          return "profile_upload"
//        case .switchEnv:            return "profile_switch_env"
        }
    }

    var vc: UIViewController {
        switch self {
        case .toBeDelivered:        return DeliveryRecordViewController(status: .toBeDelivered)
        case .delivered:            return DeliveryRecordViewController(status: .delivered)
        case .received:             return DeliveryRecordViewController(status: .received)

        case .gameRecord:           return GameRecordViewController()
        case .onePieceTaskRecord:   return YiFanShangRecordViewController()
        case .exchangeRecord:       return ExchangeRecordViewController()
        case .rechargeRecord:       return RechargeRecordViewController()

//        case .faq:                  return FAQViewController()
//        case .invite:               return InviteViewController()
//        case .myGift:               return GiftViewController()
//        case .coupon:               return CouponViewController(couponType: .AVAIL)
//        case .address:              return AddressListViewController()
//        case .uploadEvent:          return EventUploadViewController()
//        case .switchEnv:            return EnvironmentViewController()
        }
    }
}
