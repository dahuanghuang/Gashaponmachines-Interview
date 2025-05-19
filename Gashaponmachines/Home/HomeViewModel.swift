import UIKit
import RxSwift
import RxCocoa

class HomeViewModel: BaseViewModel {
    // 弹窗
    var requestPopupMenus = PublishSubject<Void>()
    let popupMenusEnvelope = PublishSubject<PopupMenusEnvelope>()

    // 标签
    var requestMachineTags = PublishSubject<Void>()
    let machineTagEnvelope = PublishSubject<HomeMachineTagEnvelope>()

    override init() {
        super.init()

        let popupMenusResponse = requestPopupMenus
            .flatMapLatest {
                AppEnvironment.current.apiService.getPopupMenus().materialize()
            }
            .share(replay: 1)

        popupMenusResponse.elements()
            .bind(to: popupMenusEnvelope)
            .disposed(by: disposeBag)

        let machineTagsResponse = requestMachineTags
            .flatMapLatest {
                AppEnvironment.current.apiService.getHomeMachineTags().materialize()
            }
            .share(replay: 1)

        machineTagsResponse.elements()
            .bind(to: machineTagEnvelope)
            .disposed(by: disposeBag)

        machineTagsResponse.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}

import Curry
import Runes
import Argo

// MARK: - 首页机台标签
public struct HomeMachineTagEnvelope {
    /// 搜索信息
    var searchInfo: HomeSearchInfo
    /// 搜索框右边活动
    var rightBarButtonInfo: HomeActivityInfo?
    /// 机台标签
    var machineTagList: [HomeMachineTag]
    /// 全部的机台类型
    var machineTypeList: [HomeMachineType]
    /// 首页活动弹窗
    var popupWindowInfo: PopupWindowInfo?
}

public struct PopupWindowInfo {
    var mainImage: String
    var buttonImage: String
    var action: String
}

/// 搜索关键字
public struct HomeSearchInfo {
    var placeholder: String?
    // 热门关键字
    var hotKeywords: [String]?
}

/// 右上角活动
public struct HomeActivityInfo {
    var action: String
    // 热门关键字
    var icon: String
}

/// 机台标签
public struct HomeMachineTag {
    /// 标签ID
    var tagId: String
    /// 标签名称
    var title: String
    /// 子标签
    var subTags: [HomeMachineSubTag]?
}

/// 机台类型
public struct HomeMachineType {
    /// 名字
    var name: String
    /// 类型
    var type: String
}

/// 子机台标签
public struct HomeMachineSubTag {
    var tagId: String
    var title: String
    var icon: String?
}

extension HomeMachineTagEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachineTagEnvelope> {
        return curry(HomeMachineTagEnvelope.init)
            <^> json <| "searchInfo"
            <*> json <|? "rightBarButtonInfo"
            <*> json <|| "machineTagList"
            <*> json <|| "machineTypeList"
            <*> json <|? "popupWindowInfo"
    }
}

extension PopupWindowInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PopupWindowInfo> {
        return curry(PopupWindowInfo.init)
            <^> json <| "mainImage"
            <*> json <| "buttonImage"
            <*> json <| "action"
    }
}

extension HomeSearchInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeSearchInfo> {
        return curry(HomeSearchInfo.init)
            <^> json <|? "placeholder"
            <*> json <||? "hotKeywords"
    }
}

extension HomeActivityInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeActivityInfo> {
        return curry(HomeActivityInfo.init)
            <^> json <| "action"
            <*> json <| "icon"
    }
}

extension HomeMachineTag: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachineTag> {
        return curry(HomeMachineTag.init)
            <^> json <| "tagId"
            <*> json <| "title"
            <*> json <||? "subTags"
    }
}

extension HomeMachineType: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachineType> {
        return curry(HomeMachineType.init)
            <^> json <| "name"
            <*> json <| "type"
    }
}

extension HomeMachineSubTag: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachineSubTag> {
        return curry(HomeMachineSubTag.init)
            <^> json <| "tagId"
            <*> json <| "title"
            <*> json <|? "icon"
    }
}

// MARK: - 首页弹窗
public struct PopupMenusEnvelope {
    var adInfo: [PopMenuAdInfo]
    var questInfo: PopMenuQuestInfo
    var signInfo: PopMenuSignInfo
}

// 运营弹窗
public struct PopMenuAdInfo {
    var mainAction: String
    var mainImage: String
    var showPage: ShowPage

    enum ShowPage: String {
        // 主页
        case Main
        // 元气赏
        case OnePiece
        // 蛋壳商城
        case Mall
        // 蛋槽
        case EggProduct
        // 我的
        case Mine
        // 机台
        case Game
        // 充值
        case Recharge

        case Unknown
    }
}

// 新手弹窗
public struct PopMenuQuestInfo {
    var mainImage: String?
    var buttonImage: String?
    var buttonAction: String?
}

// 签到弹窗
public struct PopMenuSignInfo {
    var mainImage: String?
    var mainInfo: PopMenuSignMainInfo?
}

// 签到弹窗信息
public struct PopMenuSignMainInfo {
    // 主图头部显示的标题
    var header: String
    // 主图中央显示的图标
    var icon: String
    // 折扣内容
    var title: String
    // 下方内容
    var bottom: String
    // 当签到有奖励时返回，奖励类型
    var type: String?
    // 签到奖励为 元气时返回
    var amount: String?
    // 签到奖励为 优惠券时返回
    var coupons: [PopMenuSignCoupon]?
}

// 签到优惠券
public struct PopMenuSignCoupon {
    // 优惠券模板 ID，调用签到接口时需要带上
    var couponTemplateId: String
    // 优惠券名称
    var title: String
    // 优惠券图标
    var icon: String
    // 优惠券价格
    var original: String
    // 优惠券折扣后价格
    var promo: String
    // 优惠券折扣提示
    var promoNotice: String
}

extension PopupMenusEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PopupMenusEnvelope> {
        return curry(PopupMenusEnvelope.init)
            <^> json <|| "adInfo"
            <*> json <| "questInfo"
            <*> json <| "signInfo"
    }
}

extension PopMenuAdInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PopMenuAdInfo> {
        return curry(PopMenuAdInfo.init)
            <^> json <| "mainAction"
            <*> json <| "mainImage"
            <*> json <| "showPage"
    }
}

extension PopMenuAdInfo.ShowPage: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PopMenuAdInfo.ShowPage> {
        switch json {
        case let .string(type):
            return pure(PopMenuAdInfo.ShowPage(rawValue: type) ?? PopMenuAdInfo.ShowPage.Unknown)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

extension PopMenuQuestInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PopMenuQuestInfo> {
        return curry(PopMenuQuestInfo.init)
            <^> json <|? "mainImage"
            <*> json <|? "buttonImage"
            <*> json <|? "buttonAction"
    }
}

extension PopMenuSignInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PopMenuSignInfo> {
        return curry(PopMenuSignInfo.init)
            <^> json <|? "mainImage"
            <*> json <|? "mainInfo"
    }
}

extension PopMenuSignMainInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PopMenuSignMainInfo> {
        return curry(PopMenuSignMainInfo.init)
            <^> json <| "header"
            <*> json <| "icon"
            <*> json <| "title"
            <*> json <| "bottom"
            <*> json <|? "type"
            <*> json <|? "amount"
            <*> json <||? "coupons"
    }
}

extension PopMenuSignCoupon: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PopMenuSignCoupon> {
        return curry(PopMenuSignCoupon.init)
            <^> json <| "couponTemplateId"
            <*> json <| "title"
            <*> json <| "icon"
            <*> json <| "original"
            <*> json <| "promo"
            <*> json <| "promoNotice"
    }
}
