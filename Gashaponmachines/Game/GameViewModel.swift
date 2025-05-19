import RxSwift
import RxCocoa

struct GameViewModel {

    var	refreshBalanceTrigger = PublishSubject<Void>()

    var roomInfo: Observable<RoomInfoEnvelope>

    var showNDVipWarning: Observable<Bool>

    var roomInfoError: Observable<ErrorEnvelope>

    let disposedBag = DisposeBag()

    init(roomId: String) {

        let roomInfoResponse = refreshBalanceTrigger
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getRoomInfo(roomId: roomId).materialize()
            }
            .share(replay: 1)

        self.roomInfo = roomInfoResponse.elements()

        self.roomInfoError = roomInfoResponse.errors().requestErrors()

        self.showNDVipWarning = self.roomInfo.map { $0.needNDVipWarning }.filterNil().map { $0 == "1" }
    }
}
