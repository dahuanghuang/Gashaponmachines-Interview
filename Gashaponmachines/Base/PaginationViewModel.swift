import RxSwift
import RxCocoa

protocol Pagination {

    // 请求页码
    var pageIndex: Int { get }

    // 是否没有更多数据
    var isEnd: BehaviorRelay<Bool> { get }

    // 网络请求中 初始值 false
    var loading: BehaviorRelay<Bool> { get }

    // 下拉刷新
    var refreshTrigger: PublishSubject<Void> { get }

    // 加载下一页
    var loadNextPageTrigger: PublishSubject<Void> { get }

    // 具体的 Item
    associatedtype Item
}

open class PaginationViewModel<T>: BaseViewModel, Pagination {

    typealias Item = T

    var items = BehaviorRelay<[T]>(value: [])

    var newPageIndex = BehaviorRelay<Int>(value: Constants.kDefaultPageIndex)

    var pageIndex: Int = Constants.kDefaultPageIndex

    var isEnd = BehaviorRelay<Bool>(value: false)

    var loading = BehaviorRelay<Bool>(value: false)

    var refreshTrigger = PublishSubject<Void>()

    var loadNextPageTrigger = PublishSubject<Void>()

    var request = PublishSubject<Int>()

    override init() {
        super.init()
        let refreshRequest = loading
            .asObservable()
            .sample(refreshTrigger)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { observer in
                        self.pageIndex = 1
                        observer.onNext(1)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
            }

        let nextPageRequest = loading
            .asObservable()
            .sample(loadNextPageTrigger)
            .flatMap { loading -> Observable<Int> in
                if loading || self.isEnd.value {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { observer in
                        self.pageIndex += 1
                        observer.onNext(self.pageIndex)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
            }

        // 请求的页数
        Observable
            .merge(
//                refreshRequest.debug("1", trimOutput: true),
//                nextPageRequest.debug("2", trimOutput: true)
                refreshRequest, nextPageRequest
            )
            .bind(to: request)
            .disposed(by: disposeBag)
    }
}

// open class NewPaginationViewModel<T>: BaseViewModel {
//    
//    typealias Item = T
//    
//    var items = BehaviorRelay<[T]>(value: [])
//    
//    var newPageIndex = BehaviorRelay<Int>(value: Constants.kDefaultPageIndex)
//    
//    var pageIndex: Int = Constants.kDefaultPageIndex
//    
//    var isEnd = BehaviorRelay<Bool>(value: false)
//    
//    var loading = BehaviorRelay<Bool>(value: false)
//    
//    var refreshTrigger = PublishSubject<Void>()
//    
//    var loadNextPageTrigger = PublishSubject<Void>()
//    
//    var request = PublishSubject<Int>()
//    
//    override init() {
//        super.init()
//        
//        refreshTrigger.asObserver()
//    }
// }
