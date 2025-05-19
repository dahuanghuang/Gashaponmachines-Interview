import UIKit
import RxSwift
import RxCocoa

class HomeMachineViewModel: PaginationViewModel<HomeMachine> {

    var requestMachineList = PublishSubject<String>()

    init(style: HomeMachineListStyle) {
        super.init()

        let machineListResponse = Observable.combineLatest(
            requestMachineList,
            request)
            .flatMapLatest { (value, page) -> Observable<Event<HomeMachineListEnvelope>> in
                if style == .all {
                    return AppEnvironment.current.apiService.getHomeMachineList(type: value, tagId: nil, sourceType: nil, page: page).materialize()
                } else {
                    return AppEnvironment.current.apiService.getHomeMachineList(type: nil, tagId: value, sourceType: nil, page: page).materialize()
                }
            }
            .share(replay: 1)

        // 累加数据, 保存
        Observable
            .combineLatest(request, machineListResponse.elements(), items.asObservable()) { page, res, items in

                self.isEnd.accept(res.isEnd == "1" ? true : false)

                return self.pageIndex == Constants.kDefaultPageIndex ? res.machines : items + res.machines
            }
            .sample(machineListResponse.elements())
            .bind(to: items)
            .disposed(by: disposeBag)

        Observable
        .merge(request.map { _ in true },
               machineListResponse.map { _ in false },
               error.map { _ in false })
        .bind(to: loading)
        .disposed(by: disposeBag)
    }
}
