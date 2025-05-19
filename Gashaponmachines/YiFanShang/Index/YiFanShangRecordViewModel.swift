import Argo
import Curry
import Runes

public struct YiFanShangRecordEnvelope {

    var records: [YiFanShangRecord]
}

extension YiFanShangRecordEnvelope: Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<YiFanShangRecordEnvelope> {
        return curry(YiFanShangRecordEnvelope.init)
            <^> json <|| "purchaseRecord"
    }
}

struct YiFanShangRecord {
    var title: String? // 物品名称

    var serial: String? // 元气赏期号

    var purchaseCount: String? // 购买次数

    var purchaseTimeStr: String? // 购买时间格式化字符串

    var increase: String? // 退款时的数值

    var decrease: String? // 购买成功时的数值
}

extension YiFanShangRecord: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<YiFanShangRecord> {
        return curry(YiFanShangRecord.init)
            <^> json <|? "title"
            <*> json <|? "serial"
            <*> json <|? "purchaseCount"
            <*> json <|? "purchaseTimeStr"
            <*> json <|? "increase"
            <*> json <|? "decrease"
    }
}

import RxSwift
import RxCocoa

class YiFanShangRecordViewModel: PaginationViewModel<YiFanShangRecord> {

    var envelope = PublishSubject<YiFanShangRecordEnvelope>()

    override init() {

        super.init()

        let response = request.flatMapLatest { page in
                AppEnvironment.current.apiService.getOnePiecePurchaseRecord(page: page).materialize()
            }
            .share(replay: 1)

        response.elements()
            .bind(to: envelope)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.records
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
