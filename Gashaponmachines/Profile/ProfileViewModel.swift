import Foundation
import RxSwift
import RxCocoa
//import Result
import RxOptional

class ProfileViewModel: BaseViewModel {
//    var userInfo: Driver<UserInfo>
    var userInfoEnvelope = PublishSubject<UserInfoEnvelope>()
    var viewWillAppearTrigger = PublishSubject<Void>()

    override init() {
        super.init()

        let request = viewWillAppearTrigger.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getMyselfInfoV2().materialize()
            }
            .share(replay: 1)

        request.elements()
            .bind(to: userInfoEnvelope)
            .disposed(by: disposeBag)
    }
}
