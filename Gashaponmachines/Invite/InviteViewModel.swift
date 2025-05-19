import RxSwift
import RxDataSources
import RxCocoa

class InviteViewModel: BaseViewModel {

    var viewWillAppearTrigger = PublishSubject<Void>()

    var info = PublishSubject<InvitationInfoEnvelope>()

    var inputCodeResult = PublishSubject<ResultEnvelope>()

    var inputCode = PublishSubject<String>()

    var submitButtonTap = PublishSubject<Void>()

    override init() {
        super.init()
        let infoResponse = self.viewWillAppearTrigger.asObservable()
            .flatMapLatest { _ in
            	AppEnvironment.current.apiService.getInvitationInfo().materialize()
            }
            .share(replay: 1)

        infoResponse
            .elements()
            .bind(to: info)
        	.disposed(by: disposeBag)

        let inputCodeResponse = submitButtonTap
            .asObservable()
            .withLatestFrom(self.inputCode.asObservable())
            .flatMapLatest { code in
                AppEnvironment.current.apiService.addInvitationCode(invitationCode: code).materialize()
            }
            .share(replay: 1)

        inputCodeResponse
            .elements()
            .bind(to: inputCodeResult)
            .disposed(by: disposeBag)

        Observable
            .merge(
            	inputCodeResponse.errors(),
            	infoResponse.errors()
        	)
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
