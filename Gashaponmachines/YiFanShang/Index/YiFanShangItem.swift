import Argo
import Runes
import Curry

enum YiFanShangItemStatus: String {
    // 出售中
    case selling = "10"
    // 等待中
    case waiting = "20"
    // 开奖中
    case running = "30"
    // 已结束
    case ended = "40"
    // 超时(退款)
    case timeout = "50"
    // 故障
    case error = "60"
    // 归档
    case archived = "90"

    var yfsIcon: UIImage? {
        switch self {
        case .selling:
            return UIImage(named: "yfs_list_selling")
        case  .waiting, .running:
            return UIImage(named: "yfs_list_running")
        case .ended, .timeout, .error, .archived:
            return UIImage(named: "yfs_list_ended")
        }
    }

    // 能否点击
//    var isTapEnable: Bool {
//        switch self {
//        case .selling, .waiting, .running, .ended:
//            return true
//        case .timeout, .error, .archived:
//            return false
//        }
//    }
}

public struct YiFanShangItem {

    var onePieceTaskId: String?

    var onePieceTaskRecordId: String?

    /// 当前已被买数量
    var currentCount: String?

    /// 一番赏图片
    var image: String?

    /// 买一次所需元气
    var price: String?

    /// 进度
    var progress: String?

    /// 进度说明, 有进度比例、开赏中、已结束三种形式
    var progressTip: String?

    var status: YiFanShangItemStatus?

    /// 总可买数量
    var totalCount: String?

    /// 一番赏标题
    var title: String?

    /// 跳转链接
    var link: String?
}

extension YiFanShangItemStatus: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<YiFanShangItemStatus> {
        switch json {
        case let .string(status):
            return pure(YiFanShangItemStatus(rawValue: status) ?? .selling)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }

}

extension YiFanShangItem: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<YiFanShangItem> {
        return curry(YiFanShangItem.init)
            <^> json <|? "onePieceTaskId"
            <*> json <|? "onePieceTaskRecordId"
            <*> json <|? "currentCount"
            <*> json <|? "image"
            <*> json <|? "price"
            <*> json <|? "progress"
            <*> json <|? "progressTip"
            <*> json <|? "status"
            <*> json <|? "totalCount"
            <*> json <|? "title"
            <*> json <|? "link"
    }
}

public struct YiFanShangRecordListEnvelope {

    var items: [YiFanShangItem]
    var isEnd: String?
}

extension YiFanShangRecordListEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<YiFanShangRecordListEnvelope> {

        return curry(YiFanShangRecordListEnvelope.init)
            <^> json <|| "recordList"
            <*> json <| "isEnd"
    }
}

public struct YiFanShangRuleListEnvelope {
    /// 图片URL
    var rules: [String]
    /// 详情链接
    var detailsLink: Link
}

public struct Link {
    var action: String
    var rule: String
}

extension Link: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Link> {
        return curry(Link.init)
            <^> json <| "action"
            <*> json <| "rule"
    }
}

extension YiFanShangRuleListEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<YiFanShangRuleListEnvelope> {
        return curry(YiFanShangRuleListEnvelope.init)
            <^> json <|| "rules"
            <*> json <| "detailsLink"
    }
}
