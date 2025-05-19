import RxCocoa
import RxSwift

struct CollectionSelectionViewModel {

    init(product: EggProduct, indexPath: IndexPath, cachedCollection: EggProduct.Collection?) {
        self.indexPath = Driver.just(indexPath)
        self.product.accept(product)
        self.items = Driver.just(product).map { $0.collections }.filterNil()

        // 选择状态
        selectedSubject.asObservable()
            .scan(Set()) { (acc: Set<EggProduct.Collection>, item: EggProduct.Collection) in
                var acc = acc
                if acc.isEmpty {
                    acc.insert(item)
                } else {
                    acc.removeAll()
                    acc.insert(item)
                }
                return acc
            }
            .startWith(cachedCollection != nil ? Set([cachedCollection!]) : Set())
            .bind(to: state)
            .disposed(by: disposeBag)
    }

    var selectedSubject = PublishSubject<EggProduct.Collection>()

    var state = BehaviorRelay<Set<EggProduct.Collection>>(value: Set())

    var indexPath: Driver<IndexPath>

    var product = BehaviorRelay<EggProduct?>(value: nil)

    var items: Driver<[EggProduct.Collection]>

    let disposeBag = DisposeBag()
}
