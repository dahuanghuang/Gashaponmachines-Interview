import RxSwift
import RxCocoa
import UIKit
import Argo
import Runes
import Curry

class SearchViewModel: BaseViewModel {

    var searchKeyword = PublishSubject<String>()

    var searchEnvelope = PublishSubject<SearchEnvelope>()

    init(style: SearchProductVcStyle) {
        super.init()

        let request = searchKeyword
            .flatMapLatest { keyword in
                AppEnvironment.current.apiService.getHomeSearchMachine(text: keyword, type: style.rawValue).materialize()
            }
            .share(replay: 1)

        request.elements()
            .bind(to: searchEnvelope)
            .disposed(by: disposeBag)
    }
}

public struct SearchEnvelope {
    /// 扭蛋机个数
    var machineCount: String
    /// 商品兑换个数
    var mallProductCount: String
    /// 机台列表
    var machines: [HomeMachine]
    /// 商品列表
    var mallProducts: [SearchMallProduct]
}

// public struct SearchMachine {
//    /// 机台icon图片
//    var icon: String
//    /// 机台图片
//    var image: String
//    /// 机台物理ID
//    var physicId: String
//    /// 游戏价格
//    var priceStr: String
//    ///
//    var productId: String
//    /// 状态(0-空闲, 1-游戏中)
//    var status: String
//    /// 机台名称
//    var title: String
//    /// 机台类型(1~5 对应 白、黄、绿、红、黑 )
//    var type: String
// }

public struct SearchMallProduct {
    /// 商品标题
    var title: String
    /// 商品图片
    var image: String
    /// 蛋壳值
    var worth: String
    /// 是否打折
    var isOnDiscount: String?
    /// 原价(isOnDiscount 为 1)
    var originalWorth: String?
    /// 商品ID
    var productId: String
}

extension SearchEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<SearchEnvelope> {
        return curry(SearchEnvelope.init)
            <^> json <| "machineCount"
            <*> json <| "mallProductCount"
            <*> json <|| "machines"
            <*> json <|| "mallProducts"
    }
}

// extension SearchMachine: Argo.Decodable {
//    public static func decode(_ json: JSON) -> Decoded<SearchMachine> {
//        return curry(SearchMachine.init)
//            <^> json <| "icon"
//            <*> json <| "image"
//            <*> json <| "physicId"
//            <*> json <| "priceStr"
//            <*> json <| "productId"
//            <*> json <| "status"
//            <*> json <| "title"
//            <*> json <| "type"
//    }
// }

extension SearchMallProduct: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<SearchMallProduct> {
        return curry(SearchMallProduct.init)
            <^> json <| "title"
            <*> json <| "image"
            <*> json <| "worth"
            <*> json <|? "isOnDiscount"
            <*> json <|? "originalWorth"
            <*> json <| "productId"
    }
}
