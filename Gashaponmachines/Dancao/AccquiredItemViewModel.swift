import RxSwift
import RxCocoa
import RxSwiftExt

class AccquiredItemViewModel: PaginationViewModel<EggProduct> {

    var eggProductEnvelope = PublishSubject<UserEggProductEnvelope>()

    // 选择触发器
    var selection = PublishSubject<EggProduct?>()

    //
    var eggProductType = BehaviorRelay<EggProductType>(value: .general)

    override init() {
        super.init()

        let response = Observable.combineLatest(request, eggProductType.asObservable())
            .flatMapLatest { (page, type) in
                AppEnvironment.current.apiService.getUserEggProducts(sourceType: type.rawValue, page: page).materialize()
            }
            .share(replay: 1)

        response.elements()
            .bind(to: eggProductEnvelope)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { page, res, items in
                // 请求的数据
                let responseMachines = res.products

                var products = [EggProduct]()
                for index in 0..<responseMachines.count {
                    var p = responseMachines[index]
                    p.randomId = "\(self.pageIndex)\(index)"
                    products.append(p)
                }

                self.isEnd.accept(res.isEnd == "1" ? true : false)

                return self.pageIndex == Constants.kDefaultPageIndex ? products : items + products
            }
            .sample(response.elements())
            .bind(to: items)
            .disposed(by: disposeBag)

        Observable
            .merge(request.map { _ in true },
                   response.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)

        response
            .errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}

import Curry
import Runes
import Argo
import ESTabBarController_swift

enum EggProductType: Int, CaseIterable {
    case general = 10 // 一般蛋槽
    case pieceEgg = 30 // 集集乐
    case oneprice = 20 // 元气赏蛋槽

    var indexValue: Int {
        switch self {
        case .general:
            return 0
        case .pieceEgg:
            return 1
        case .oneprice:
            return 2
        }
    }

    var normalImage: String {
        switch self {
        case .general:
            return "dancao_general_normal"
        case .pieceEgg:
            return "dancao_pieceEgg_normal"
        case .oneprice:
            return "dancao_oneprice_normal"
        }
    }

    var selectedImage: String {
        switch self {
        case .general:
            return "dancao_general_select"
        case .pieceEgg:
            return "dancao_pieceEgg_select"
        case .oneprice:
            return "dancao_oneprice_select"
        }
    }

    var title: String {
        switch self {
        case .general:
            return "扭蛋"
        case .pieceEgg:
            return "合成"
        case .oneprice:
            return "元气赏"
        }
    }

    func look() {
        switch self {
        case .general:
            if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
                root.selectedIndex = 0
            }
        case .pieceEgg:
            RouterService.route(to: "yqnd://yqnd.quqqi.com/Compose")
        case .oneprice:
            if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
                root.selectedIndex = 1
            }
        }
    }
}

// MARK: - 用户蛋槽列表
public struct UserEggProductEnvelope {
    var products: [EggProduct]
    var count: UserEggProductCount
    // 是否是最后一页，0 表示不是，1 表示是最后一页
    var isEnd: String
    // 兑换蛋壳提示文字
    var eggExchangeTip: String
}

//
public struct UserEggProductCount {
    // 元气赏扭蛋个数
    var onePieceEggCount: String
    // 一般扭蛋个数
    var gameEggCount: String
    // 集集乐扭蛋个数
    var pieceEggCount: String
}

extension UserEggProductEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserEggProductEnvelope> {
        return curry(UserEggProductEnvelope.init)
            <^> json <|| "products"
            <*> json <| "count"
            <*> json <| "isEnd"
            <*> json <| "eggExchangeTip"
    }
}

extension UserEggProductCount: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserEggProductCount> {
        return curry(UserEggProductCount.init)
            <^> json <| "onePieceEggCount"
            <*> json <| "gameEggCount"
            <*> json <| "pieceEggCount"
    }
}
