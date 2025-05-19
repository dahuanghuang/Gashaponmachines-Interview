import Foundation
import RxCocoa
import RxSwift
import Argo
import Runes
import Curry

// enum ErrorCode: String {
//    case empty = "4703" // 全部卖完
//    case notEnough = "4100" // 剩余份数不足
// }

public struct PurchaseResultEnvelope {
    var data: PurchaseRest?
    var code: String
    var msg: String
}

public struct PurchaseRest {
    var restCount: String?
}

extension PurchaseResultEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PurchaseResultEnvelope> {
        return curry(PurchaseResultEnvelope.init)
            <^> json <|? "data"
            <*> json <| "code"
            <*> json <| "msg"
    }
}

extension PurchaseRest: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PurchaseRest> {
        return curry(PurchaseRest.init)
            <^> (json <|? "restCount" <|> (json <|? "restCount").map(Int.toString))
    }
}

/// 元气赏购买ViewModel
class YiFanShangPurchaseViewModel: BaseViewModel {
    var purchaseResult = PublishSubject<PurchaseResultEnvelope>()
    var purchaseSignal = PublishSubject<Int>()

    init(onePieceTaskRecordId: String, count: Int) {
        super.init()

        let purchaseResponse = purchaseSignal.asObservable()
            .flatMapLatest { count in
                AppEnvironment.current.apiService.buyOnePieceAward(onePieceTaskRecordId: onePieceTaskRecordId, count: count).materialize()
            }
            .share(replay: 1)

        purchaseResponse.elements()
            .bind(to: purchaseResult)
            .disposed(by: disposeBag)

        purchaseResponse.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)

    }
}

/// 魔法阵购买ViewModel
class YiFanShangMagicPurchaseViewModel: BaseViewModel {

    var purchaseSignal = PublishSubject<[String]>()
    var purchaseResult = PublishSubject<PurchaseResultEnvelope>()

    init(onePieceTaskRecordId: String) {
        super.init()
        
        let purchaseResponse = purchaseSignal.asObservable()
            .flatMapLatest { numbers in
                AppEnvironment.current.apiService.buyOnePieceMagicAward(onePieceTaskRecordId: onePieceTaskRecordId, numbers: numbers).materialize()
            }
            .share(replay: 1)
        
        purchaseResponse.elements()
            .bind(to: purchaseResult)
            .disposed(by: disposeBag)
        
        purchaseResponse.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
