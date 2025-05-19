import RxSwift
import RxDataSources
import RxCocoa

class CompositionDetailViewModel: BaseViewModel {

    var viewWillAppearTrigger = PublishSubject<Void>()

    var envelope = PublishSubject<ComposePathDetailEnvelope>()

    var lockButtonTap = PublishSubject<[String]>()

    var composeButtonTap = PublishSubject<Void>()

    var details = BehaviorRelay<[ComposeDetail]>(value: [])

    var composeResult = PublishRelay<ResultEnvelope>()

    var lockResult = PublishRelay<ResultEnvelope>()

    init(composePathId: String) {
        super.init()

        let compositionDetail =
            Observable.merge(self.viewWillAppearTrigger.asObservable(),
                             self.composeResult.asObservable().mapTo(()).delay(.seconds(2), scheduler: MainScheduler.instance),
                             self.lockResult.asObservable().mapTo(()).delay(.seconds(2), scheduler: MainScheduler.instance))
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getComposePathDetail(composePathId: composePathId).materialize()
            }
            .share(replay: 1)

        compositionDetail
            .elements()
            .bind(to: envelope)
            .disposed(by: disposeBag)

        envelope.map { $0.composeDetail }
        	.bind(to: details)
            .disposed(by: disposeBag)

        let lockRequest = self.lockButtonTap.asObservable()
            .flatMapLatest { orderIds in
                AppEnvironment.current.apiService.lockComposeOrders(composePathId: composePathId, orderIds: orderIds).materialize()
        	}
            .share(replay: 1)

        let composeRequest = self.composeButtonTap.asObservable()
            .flatMapLatest { pathId in
                AppEnvironment.current.apiService.composeProduct(composePathId: composePathId).materialize()
        	}
            .share(replay: 1)

       	lockRequest.elements()
        	.bind(to: self.lockResult)
        	.disposed(by: disposeBag)

        composeRequest.elements()
            .bind(to: self.composeResult)
            .disposed(by: disposeBag)

        Observable.merge(
        		lockRequest.errors(),
                compositionDetail.errors(),
            	composeRequest.errors()
        	)
        	.requestErrors()
        	.bind(to: error)
        	.disposed(by: disposeBag)
    }
}
