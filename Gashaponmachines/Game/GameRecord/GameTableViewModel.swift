import RxCocoa
import RxSwift
import RxSwiftExt
import RxDataSources

struct GameLuckyRecordTableViewModel {
    var records: Driver<[LuckyEggRecordEnvelope.Record]>
    var roomId = PublishSubject<String>()
    var error: Observable<ErrorEnvelope>
    init() {

        let response = self.roomId.asObservable()
            .flatMapLatest { roomId in
                AppEnvironment.current.apiService.getLuckyEggRecord(roomId: roomId).materialize()
        	}

        self.records = response
            .elements()
            .map { $0.records }
            .asDriver(onErrorJustReturn: [])

        self.error = response.errors().requestErrors()
    }

    func configureWith(roomId: String) {
        self.roomId.onNext(roomId)
    }
}

struct GameProductTableViewModel {
    var products: Driver<[Product]>
    var roomId = PublishSubject<String>()
    var luckyProduct: Driver<Product>
    var error: Observable<ErrorEnvelope>
    init() {

        let response = self.roomId.asObserver()
            .flatMapLatest { roomId in
                AppEnvironment.current.apiService.getAwardDetail(roomId: roomId).materialize()
            }
            .share(replay: 1)

        self.luckyProduct = response.elements()
            .map { $0.products?.first }
        	.filterNil()
            .map { $0 }
        	.asDriver(onErrorDriveWith: .never())

        self.products = response.elements()
            .map { env -> [Product] in
                var products = env.products ?? []
                if !products.isEmpty {
                    products.removeFirst()
                }
                return products
            }
            .asDriver(onErrorJustReturn: [])

        self.error = response.errors().requestErrors()
    }

    func configureWith(roomId: String) {
        self.roomId.onNext(roomId)
    }
}

struct GameComboTableViewModel {
    var roomId = PublishSubject<String>()
    var images: Driver<[String]>
    var error: Observable<ErrorEnvelope>
    init() {

        let response = self.roomId.asObserver()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getGamePlayIntro().materialize()
            }
            .share(replay: 1)

        self.images = response
            .elements()
            .map { $0.images }
            .filterNil()
            .asDriver(onErrorJustReturn: [])

        self.error = response.errors()
            .requestErrors()
    }

    func configureWith(roomId: String) {
        self.roomId.onNext(roomId)
    }
}
