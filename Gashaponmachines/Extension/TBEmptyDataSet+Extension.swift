import TBEmptyDataSet

protocol DataEmptyable: TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {
    var type: EmptyDataSetType { get }
}

extension DataEmptyable {

    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: type.imageName)
    }

    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let str = NSAttributedString(string: type.title,
                                     attributes:
            [
                NSAttributedString.Key.font: type.font,
                NSAttributedString.Key.foregroundColor: type.foregroundColor
            ])
        return str
    }

    func verticalOffsetForEmptyDataSet(in scrollView: UIScrollView) -> CGFloat {
        return 20
    }

    func verticalSpacesForEmptyDataSet(in scrollView: UIScrollView) -> [CGFloat] {
        return [0]
    }
}

enum EmptyDataSetType {
    case addressList
    case addressListManagement
    case delivery
    case deliveryRecordList
    case exchange
    case exchangeRecord
    case rechargeRecord
    case mallRecord
    case mallCategory
    case mallCollection
    case mallDistinctExchangeRecord
	case gameRecord
    case composition
    case notification

    var imageName: String {
        switch self {
        case .addressList,
            .addressListManagement,
            .deliveryRecordList:
            return "emptyState_delivery"
        case .delivery,
            .exchange:
            return "emptyState_dancao"
        case .exchangeRecord,
            .rechargeRecord,
        	.mallRecord,
        	.mallCategory,
        	.mallCollection,
        	.mallDistinctExchangeRecord,
            .gameRecord:
            return "emptyState_record"
        case .notification,
             .composition:
            return "emptyState_record_black"
        }
    }

    var font: UIFont {
        return UIFont.withBoldPixel(28)
    }

    var title: String {
        switch self {
        case .addressList,
             .addressListManagement:
            return "你还没有创建收货地址"
        case .delivery:
            return "发货列表为空"
        case .deliveryRecordList:
            return "暂无物流信息"
        case .exchange:
            return "兑换列表为空"
        case .exchangeRecord,
             .rechargeRecord,
             .mallRecord,
             .mallCategory,
             .gameRecord:
            return "暂无明细"
        case .mallCollection,
             .mallDistinctExchangeRecord,
             .notification,
             .composition:
            return "暂无数据"
        }
    }

    var foregroundColor: UIColor {
        switch self {
        case .notification,
             .composition:
            return UIColor.qu_black
        default:
            return UIColor.qu_lightGray
        }
    }
}

extension AddressListViewController: DataEmptyable {
    var type: EmptyDataSetType {
        return .addressList
    }
}

//extension AddressListManagementViewController: DataEmptyable {
//    var type: EmptyDataSetType {
//        return .addressListManagement
//    }
//}

extension DeliveryViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .delivery
    }
}

extension DeliveryRecordListViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .deliveryRecordList
    }
}

extension ExchangeViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .exchange
    }
}

extension ExchangeRecordViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .exchangeRecord
    }
}

extension RechargeRecordViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .rechargeRecord
    }
}

extension MallRecordViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .mallRecord
    }
}

extension MallCategoryViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .mallCategory
    }
}

extension MallCollectionViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .mallCollection
    }
}

// extension MallDistinctExchangeRecordViewController: DataEmptyable {
//    var type: EmptyDataSetType {
//        return .mallDistinctExchangeRecord
//    }
// }

extension GameRecordViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .gameRecord
    }
}

extension NotificationViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .notification
    }
}

extension CompositionViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .composition
    }
}

extension YiFanShangPurchaseRecordListViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .gameRecord
    }
}

extension YiFanShangRecordViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .gameRecord
    }
}

extension CouponViewController: DataEmptyable {

    var type: EmptyDataSetType {
        return .gameRecord
    }
}
