import RxCocoa
import RxSwift

struct ReportCrashViewModel {

    var submitResult: Driver<ResultEnvelope>
    var error: Observable<ErrorEnvelope>
    var buttonTap = PublishSubject<Void>()
    var detail = PublishSubject<String?>()
    var contact = PublishSubject<String?>()
    var cause = PublishSubject<String>()

    init(physicId: String) {
        let param = Observable.combineLatest(
            self.cause.asObservable(),
            self.detail.asObservable().filterNil(),
            self.contact.asObservable()
        )
        .map { pair in
            (physicId: physicId, cause: pair.0, detail: pair.1, contact: pair.2)
        }

        let request =
            self.buttonTap.asObservable()
            .withLatestFrom(param)
            .flatMapLatest { pair in
            	AppEnvironment.current.apiService.reportCrash(physicId: pair.physicId,
                                                              cause: pair.cause,
                                                              detail: pair.detail,
                                                              contact: pair.contact)
                    .materialize()
        	}
            .share(replay: 1)

        self.submitResult = request
        	.elements()
        	.asDriver(onErrorDriveWith: .never())

        self.error = request.errors()
            .requestErrors()
    }
}
