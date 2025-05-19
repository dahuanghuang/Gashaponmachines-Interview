import RxDataSources

enum RechargeSectionModel {
    case optionSection(items: [RechargeSectionItem])
}

enum RechargeSectionItem {
    // 普通充值
    case optionSectionItem(balance: String, options: [PaymentOption])
}

extension RechargeSectionModel: SectionModelType {

    var items: [RechargeSectionItem] {
        switch self {
        case .optionSection(items: let items):
            return items.map { $0 }
        }
    }

    init(original: RechargeSectionModel, items: [RechargeSectionItem]) {
        switch original {
        case let .optionSection(items):
            self = .optionSection(items: items)
        }
    }

    typealias Item = RechargeSectionItem
}
