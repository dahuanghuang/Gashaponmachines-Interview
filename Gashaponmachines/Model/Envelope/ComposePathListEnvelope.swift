import Argo
import Runes
import Curry
import RxDataSources

/// ComposePathListEnvelope
public struct ComposePathListEnvelope {
    var paths: [ComposePath]
    var rule: String?
    var introImage: String?
}

extension ComposePathListEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<ComposePathListEnvelope> {
        return curry(ComposePathListEnvelope.init)
            <^> json <|| "composePathList"
        	<*> json <|? "rule"
            <*> json <|? "introImage"
    }
}

enum ComposeStatus: String, Argo.Decodable {
    // 可合成（红色按钮）
    case ok = "OK"
    // 材料不足（暗红色按钮）
    case notEnough = "NOT_ENOUGH"
    // 已达合成上限（灰色按钮）
    case reachLimit = "REACH_LIMIT"
    // 已达今日合成上线(灰色按钮)
    case reachDayLimit = "REACH_DAY_LIMIT"
    // 来晚了已兑换完（灰色按钮）
    case soldOut = "SOLD_OUT"
}

/// ComposePathDetail
public struct ComposePathDetailEnvelope {
    var title: String
    var image: String
    var introImages: [String]
    var originalWorth: Int
    var worth: Int
    var composeStatus: ComposeStatus
    var composeStatusTip: String
    var composeStatusSubTip: String?
    var progress: ComposePath.Progress
    var composeDetail: [ComposeDetail]
    var announcements: [String]
    var description: String
    var label: String?
}

extension ComposePathDetailEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ComposePathDetailEnvelope> {
        let a = curry(ComposePathDetailEnvelope.init)
            <^> json <| "title"
        	<*> json <| "image"
            <*> json <|| "introImages"
            <*> (json <| "originalWorth").map(String.toInt)
        return a <*> (json <| "worth").map(String.toInt)
            <*> json <| "composeStatus"
            <*> json <| "composeStatusTip"
            <*> json <|? "composeStatusSubTip"
            <*> json <| "progress"
        	<*> json <|| "progressDetail"
        	<*> json <|| "announcement"
        	<*> json <| "description"
        	<*> (json <|? "label" <|> pure(""))
    }
}

struct ComposeDetail {
    var title: String
    var materials: [ComposeMaterial]
    var canLockAll: Bool
    var totalCount: Int
    var ownCount: Int
    var hasReachAll: Bool
    var notice: String
    var action: String
}

extension ComposeDetail: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ComposeDetail> {
        return curry(ComposeDetail.init)
            <^> json <| "title"
        	<*> json <|| "material"
        	<*> (json <| "canLockAll").map(String.toBool)
        	<*> (json <| "totalCount").map(String.toInt)
        	<*> (json <| "ownCount").map(String.toInt)
        	<*> (json <| "hasReachAll").map(String.toBool)
            <*> (json <| "notice")
            <*> (json <| "action")
    }
}

struct ComposeMaterial {
    var orderId: String
    var image: String
    var icon: String
    var lockStatus: LockStatus

    enum LockStatus: String, Argo.Decodable {
        // 已锁定
        case locked = "LOCKED"
        // 可锁定
        case canLock = "OK"
        // 不可锁定
        case forbid = "FORBID"

        var title: String {
            switch self {
            case .canLock, .forbid:
                return "锁定"
            case .locked:
                return "已锁定"
            }
        }

        var color: UIColor {
            switch self {
            case .canLock:
                return .qu_darkBlue
            default:
                return .compos_borderColor
            }
        }

        var isEnabled: Bool {
            switch self {
            case .canLock:
                return true
            default:
                return false
            }
        }
    }

    static let empty = ComposeMaterial(orderId: "", image: "", icon: "", lockStatus: .forbid)
}

extension ComposeMaterial: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ComposeMaterial> {
        return curry(ComposeMaterial.init)
            <^> json <| "orderId"
        	<*> json <| "image"
        	<*> json <| "icon"
        	<*> json <| "lockStatus"
    }
}

public struct ComposePath {
    var title: String?
    var image: String?
    var label: String?
    var originalWorth: String
    var worth: String
    var progress: Progress
    var composePathId: String

    public struct Progress {
        var totalMaterialCount: Int
        var ownMaterialCount: Int
        var lockMaterialCount: Int
        var percentage: String
    }
}

extension ComposePath: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<ComposePath> {
        return curry(ComposePath.init)
            <^> json <|? "title"
            <*> json <|? "image"
            <*> json <|? "label"
            <*> json <| "originalWorth"
            <*> json <| "worth"
            <*> json <| "progress"
            <*> json <| "composePathId"
    }
}

extension ComposePath.Progress: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<ComposePath.Progress> {
        return curry(ComposePath.Progress.init)
            <^> (json <| "totalMaterialCount").map(String.toInt)
            <*> (json <| "ownMaterialCount").map(String.toInt)
            <*> (json <| "lockMaterialCount").map(String.toInt)
            <*> json <| "percentage"
    }
}
