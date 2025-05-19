import RxSwift
import RxCocoa
import RxSwiftExt

enum NotificationSelectionEvent {
    case once(String)
    case all

    func isAllEvent() -> Bool {
        switch self {
        case .once:
            return false
        case .all:
            return true
        }
    }
}

class NotificationViewModel: PaginationViewModel<Notice> {

    var viewDidLoadTrigger = PublishSubject<Void>()

    var state = BehaviorRelay<Set<String>>(value:
        AppEnvironment.userDefault.setForKey(key: NotificationViewController.NotificationReadNoticesUserDefaultKey) ?? Set()
    )

	var selection = PublishSubject<NotificationSelectionEvent>()

    override init() {
        super.init()

        self.selection
            .asObservable()
            .scan(self.state.value) { (acc: Set<String>, event: NotificationSelectionEvent) in
                var acc = acc
                switch event {
                case .once(let notificationId):
                    if !acc.contains(notificationId) {
                        acc.insert(notificationId)
                    }
                case .all:
                    acc.removeAll()
                    acc = Set(self.items.value.map { $0.notificationId })
                }
                return acc
            }
            .bind(to: self.state)
            .disposed(by: disposeBag)

        self.state.asObservable()
            .subscribe(onNext: { set in
                AppEnvironment.userDefault.setSet(set, for: NotificationViewController.NotificationReadNoticesUserDefaultKey)
                AppEnvironment.userDefault.synchronize()
            })
        	.disposed(by: disposeBag)

        let response =
            Observable.merge(request, viewDidLoadTrigger.mapTo(1))
                .flatMapLatest { page in
                    AppEnvironment.current.apiService.getNotificationList(page: page).materialize()
                }
                .share(replay: 1)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.notifications
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
