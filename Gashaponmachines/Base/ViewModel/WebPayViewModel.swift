import UIKit
import RxSwift
import RxCocoa

class WebPayViewModel: BaseViewModel {

    // 请求签名
    var requestSign = PublishSubject<String>()
    /// 支付宝支付
    var aliPayOrderEnvelope = PublishSubject<PayOrderEnvelope>()
    /// 订单号码
    var alipayOutTradeNumber = PublishSubject<String>()
    /// 向服务器查询支付状态
    var queryedResult = PublishSubject<QueryPayOrderEnvelope>()
    /// 查询订单请求出错
    var queryOrderError = PublishSubject<ErrorEnvelope>()
    /// 尝试查询订单状态的次数
    var retryQueryCount = BehaviorRelay<Int>(value: 0)

    override init() {
        super.init()

        let alipayOrderResponse = requestSign
            .flatMapLatest { type in
                AppEnvironment.current.apiService.joinSignIn(type: type).materialize()
            }
            .share(replay: 1)

        alipayOrderResponse.elements()
            .bind(to: aliPayOrderEnvelope)
            .disposed(by: disposeBag)

        let queryResultResponse = alipayOutTradeNumber
            .flatMapLatest { tradeNum in
                AppEnvironment.current.apiService.queryPayOrder(outTradeNumber: tradeNum).materialize()
            }
            .share(replay: 1)

        queryResultResponse.elements()
            .bind(to: queryedResult)
            .disposed(by: disposeBag)

        queryResultResponse.errors()
            .requestErrors()
            .bind(to: queryOrderError)
            .disposed(by: disposeBag)
    }
}
