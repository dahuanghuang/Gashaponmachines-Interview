import RxSwift
import RxCocoa

class PhoneViewModel: BaseViewModel {

    var sendCodeTrigger = PublishSubject<String>()

    var bindPhoneTrigger = PublishSubject<(String, String)>()

    var sendCodeEnvelope = PublishSubject<ResultEnvelope>()

    var bindPhoneEnvelope = PublishSubject<ResultEnvelope>()

    override init() {
        super.init()

        let sendCodeResponse = sendCodeTrigger.asObservable()
            .flatMapLatest { phone in
                AppEnvironment.current.apiService.setVerifyCode(target: "BIND_PHONE", phone: phone).materialize()
            }
            .share(replay: 1)

        sendCodeResponse
            .elements()
            .bind(to: sendCodeEnvelope)
            .disposed(by: disposeBag)

        let bindPhoneResponse = bindPhoneTrigger.asObservable()
            .flatMapLatest { pair in
                AppEnvironment.current.apiService.bindPhone(phone: pair.0, code: pair.1).materialize()
            }
            .share(replay: 1)

        bindPhoneResponse.elements()
            .bind(to: bindPhoneEnvelope)
            .disposed(by: disposeBag)

        Observable.merge(sendCodeResponse.errors(), bindPhoneResponse.errors())
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }

}
