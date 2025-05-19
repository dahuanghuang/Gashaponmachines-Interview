import RxCocoa
import RxSwift

class MallLoginViewModel {

    var phone = BehaviorSubject<String>(value: "")
    var password = BehaviorSubject<String>(value: "")
    var error: Observable<ErrorEnvelope>
    var logined: Driver<LoginEnvelope>

    init(input: (phone: Driver<String>, password: Driver<String>, loginTap: Signal<Void>)) {

        let inputText = Driver.combineLatest(
            input.phone,
            input.password
        ) { (phone: $0, password: $1) }

        let loginRequest = input.loginTap.asObservable()
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(inputText).flatMapLatest { pair in
            	AppEnvironment.current.apiService.login(loginType: "email", certificate: pair.phone, password: pair.password).materialize()
        	}
            .share(replay: 1)

        self.logined = loginRequest.elements().asDriver(onErrorDriveWith: .never())

        self.error = loginRequest.errors().requestErrors()
    }
}
