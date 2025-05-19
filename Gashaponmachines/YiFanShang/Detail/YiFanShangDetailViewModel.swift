import RxSwift
import RxCocoa

class YiFanShangDetailViewModel: BaseViewModel {

    var detailEnvelope = PublishSubject<YiFanShangDetailEnvelope>()

    var viewDidLoadTrigger = PublishSubject<Void>()

    init(onePieceTaskRecordId: String) {

        super.init()

        let request = viewDidLoadTrigger
            .flatMapLatest {
                AppEnvironment.current.apiService.getOnePieceTaskRecordDetail(onePieceTaskRecordId: onePieceTaskRecordId).materialize()
            }
            .share(replay: 1)

        request.elements()
            .bind(to: detailEnvelope)
            .disposed(by: disposeBag)
        
        request.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}

import Curry
import Runes
import Argo

public struct YiFanShangDetailEnvelope {
    /// 一番赏ID
    var onePieceTaskRecordId: String?
    /// A~F赏
    var awardInfo: [AwardInfo]?
    /// 元气余额
    var balance: String?
    /// 购买类型
    var actionButtonType: ActionButtonType?
    /// 当前卖的号码数量
    var currentCount: String?
    /// 拥有的号码数列表
    var ownTickets: [String]?
    /// 拥有的号码总数
    var ownTicketsCount: String?
    /// 买一次价格
    var price: String?
    /// 进度
    var progress: String?
    /// 第几弹
    var serial: String?
    /// 总号码数
    var totalCount: String?
    /// 购买的劵
    var ticketList: [Ticket]?
    // 是否支持魔法阵，1: 支持，0: 不支持
    var isMagic: Bool?
    /// 魔法阵相关
    var magicDetail: MagicDetail?
    /// 商品标题
    var title: String?
}

public struct MagicDetail {
    /// 我的积分
    var myPointText: String
    /// 魔法可开启次数
    var canBuyCount: Int
    /// 魔法进度
    var nextProgress: Float
//    /// 黑金卡加速
    var blackGoldMultiplierText: String
    /// 等级加速
    var expLevelMultiplierText: String
    /// 魔法阵价格
    var magicPrice: String
    /// 魔法值余额
    var magicPointBalance: String
    // 拥有的魔法阵号码数列表
    var ownMagicTickets: [String]
    // 跳转链接
    var ruleURL: String?
}

public enum ActionButtonType: String {
    // 可以购买
    case canPurchase = "1"
    // 不能购买
    case canNotPurchased = "2"
    // 查看详情
    case detail = "3"
}

/// 劵
public struct Ticket {
    /// 昵称
    var nickname: String?
    /// 头像
    var avatar: String?
    /// 头像框
    var avatarFrame: String?
    /// 购买时间
    var purchaseTime: String?
    /// 购买时间戳
    var purchaseTimeStr: String?
    /// 购买个数
    var purchaseCount: String?
    /// 是否为魔法劵
    var isMagic: Bool
    /// 魔法阵号码（isMagic为1时有）
    var number: String?
}

/// 赏
public struct AwardInfo {
    /// 商品跳转链接
    var action: String?
    /// 赏图片
    var eggBackgroundImage: String?
    /// 赏个数
    var eggCount: String?
    /// 商品描述
    var eggDescription: String?
    /// 蛋图片
    var eggIcon: String?
    /// 赏名称
    var eggTitle: String?
    /// 赏的蛋壳价值
    var productWorth: String?
    /// 商品类型
    var eggType: String?
    /// A赏小图商品图片
    var productImage: String?
    /// A赏大图商品图片
    var productHorizontalImage: String?
    /// 商品名称
    var productTitle: String?
    /// 商品详情的赏图片
    var bigAwardIcon: String?
    /// 商品的介绍图片
    var productIntroImages: [String]
}

extension ActionButtonType: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<ActionButtonType> {
        switch json {
        case let .string(actionButtonType):
            return pure(ActionButtonType(rawValue: actionButtonType) ?? .canPurchase)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

extension MagicDetail: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MagicDetail> {
        return curry(MagicDetail.init)
            <^> json <| "myPointText"
            <*> (json <| "canBuyCount" <|> (json <| "canBuyCount").map(String.toInt))
            <*> (json <| "nextProgress" <|> (json <| "nextProgress").map(String.toFloat))
            <*> json <| "blackGoldMultiplierText"
            <*> json <| "expLevelMultiplierText"
            <*> json <| "magicPrice"
            <*> json <| "magicPointBalance"
            <*> json <|| "ownMagicTickets"
            <*> json <|? "ruleURL"
    }
}

extension Ticket: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Ticket> {
        return curry(Ticket.init)
            <^> json <|? "nickname"
            <*> json <|? "avatar"
            <*> json <|? "avatarFrame"
            <*> json <|? "purchaseTime"
            <*> json <|? "purchaseTimeStr"
            <*> (json <|? "purchaseCount" <|> (json <|? "purchaseCount").map(Int.toString))
            <*> (json <| "isMagic" <|> (json <| "isMagic").map(String.toBool))
            <*> json <|? "number"
    }
}

extension AwardInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<AwardInfo> {
        return curry(AwardInfo.init)
            <^> json <| "action"
            <*> json <| "eggBackgroundImage"
            <*> json <| "eggCount"
            <*> json <| "eggDescription"
            <*> json <| "eggIcon"
            <*> json <| "eggTitle"
            <*> json <| "productWorth"
            <*> json <| "eggType"
            <*> json <| "productImage"
            <*> json <|? "productHorizontalImage"
            <*> json <| "productTitle"
            <*> json <|? "bigAwardIcon"
            <*> json <|| "productIntroImages"
    }
}

extension YiFanShangDetailEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<YiFanShangDetailEnvelope> {
        let a = curry(YiFanShangDetailEnvelope.init)
            <^> json <|? "onePieceTaskRecordId"
            <*> json <||? "awardInfo"
        let b = a <*> json <|? "balance"
            <*> json <|? "actionButtonType"
            <*> json <|? "currentCount"
            <*> json <||? "ownTickets"
        let c = b <*> json <|? "ownTicketsCount"
            <*> json <|? "price"
            <*> json <|? "progress"
        return c <*> json <|? "serial"
            <*> json <|? "totalCount"
            <*> json <||? "ticketList"
            <*> (json <|? "isMagic" <|> (json <|? "isMagic").map(String.toBool))
            <*> json <|? "magicDetail"
            <*> json <|? "title"
    }
}

public struct YiFanShangPurchaseEnvelope {
    var img: String
}

extension YiFanShangPurchaseEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<YiFanShangPurchaseEnvelope> {
        return curry(YiFanShangPurchaseEnvelope.init)
            <^> json <| "img"
    }
}
