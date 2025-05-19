import RxSwift
import RxCocoa

struct AppDelegateViewModel {

    var logout = PublishSubject<Void>()

    var applicationDidBecomeActive = PublishSubject<UIApplication>()

    var applicationDidEnterBackground = PublishSubject<UIApplication>()

    let disposeBag = DisposeBag()

    var staticAssets: StaticAssetsEnvelope?

    init() {

        self.logout.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.logoutRequest().materialize()
        	}
        	.share(replay: 1)
        	.subscribe()
        	.disposed(by: disposeBag)

        self.applicationDidBecomeActive
        	.asObservable()
            .subscribe(onNext: { application in
                application.applicationIconBadgeNumber = 0
            })
            .disposed(by: disposeBag)

        self.applicationDidEnterBackground
        	.asObservable()
            .subscribe(onNext: { application in
                PushService.shared.syncBadgeNum(count: application.applicationIconBadgeNumber)
            })
        	.disposed(by: disposeBag)
    }
}
