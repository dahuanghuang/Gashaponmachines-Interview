import RxSwift
import RxCocoa
import Argo
import Runes
import Curry

class YiFanShangPurchaseRecordListViewModel: PaginationViewModel<YiFanShangPurchaseRecord> {

    var envelope = PublishSubject<YiFanShangPurchaseRecordListEnvelope>()

    init(onePieceTaskRecordId: String) {
        super.init()

        let response = request.flatMapLatest { page in
            AppEnvironment.current.apiService.getOnePieceJoinRecord(onePieceTaskRecordId: onePieceTaskRecordId, page: page).materialize()
        }
        .share(replay: 1)

        response.elements()
            .bind(to: envelope)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.items ?? []
                self.isEnd.accept(responseMachines.count < Constants.kDefaultPageLimit)
                return self.pageIndex == Constants.kDefaultPageIndex ? responseMachines : array + responseMachines
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

        response.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)

    }
}

public struct YiFanShangPurchaseRecordListEnvelope {

    var items: [YiFanShangPurchaseRecord]?
}

extension YiFanShangPurchaseRecordListEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<YiFanShangPurchaseRecordListEnvelope> {
        return curry(YiFanShangPurchaseRecordListEnvelope.init)
            <^> json <||? "joinRecord"
    }
}

struct YiFanShangPurchaseRecord {
    /// 号码
    var numbers: [String]?
    /// 号码个数
    var count: String?
    /// 购买时间
    var purchaseTime: String?

    var purchaseTimeStr: String?
    /// 是否为魔法阵
    var isMagic: Bool
    /// 魔力值消耗量，仅isMagic为1时存在
    var cost: String?
}

extension YiFanShangPurchaseRecord: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<YiFanShangPurchaseRecord> {
        return curry(YiFanShangPurchaseRecord.init)
            <^> json <||? "numbers"
            <*> json <|? "count"
            <*> json <|? "purchaseTime"
            <*> json <|? "purchaseTimeStr"
            <*> (json <| "isMagic" <|> (json <| "isMagic").map(String.toBool))
            <*> json <|? "cost"
    }
}
