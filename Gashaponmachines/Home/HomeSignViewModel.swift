import UIKit
import RxSwift
import RxCocoa

class HomeSignViewModel: BaseViewModel {

    // 签到
    var requestSignIn = PublishSubject<String?>()
    var signInResult = PublishSubject<ResultEnvelope>()

    override init() {
        super.init()

        let signInResponse = requestSignIn
            .flatMapLatest { couponTemplateId in
                AppEnvironment.current.apiService.signIn(couponTemplateId: couponTemplateId).materialize()
            }
            .share(replay: 1)

        signInResponse.elements()
            .bind(to: signInResult)
            .disposed(by: disposeBag)

        signInResponse.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
