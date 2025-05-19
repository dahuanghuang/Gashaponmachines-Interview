import RxCocoa
import RxSwift
import RxDataSources

struct ExchangeDetailViewModel {
    var viewWillAppearTrigger = PublishSubject<Void>()

    // drive by the modelSelected method
    var selectionObserver: AnyObserver<EggProduct>
    // bind to cell for selected UI configuration
    var state: Driver<Set<EggProduct>>
    var products: Driver<[EggProduct]>

    var submit: Driver<Set<EggProduct>>

    private var selectedSubject = PublishSubject<EggProduct>()

    init(allProducts: [EggProduct], selectedProducts: [EggProduct]?, submitSignal: Signal<Void>) {

        self.products = self.viewWillAppearTrigger.asObservable()
            .withLatestFrom(Observable.just(allProducts))
        	.asDriver(onErrorJustReturn: [])

        self.selectionObserver = selectedSubject.asObserver()

        var initialSelectedProducts: [EggProduct]
        if let selectedProducts = selectedProducts {
            initialSelectedProducts = selectedProducts
        } else {
            initialSelectedProducts = allProducts
        }

        self.state = selectedSubject.asObserver()
            .scan(Set(initialSelectedProducts)) { (acc: Set<EggProduct>, item: EggProduct) in
                // store disabled item
                var acc = acc
                if acc.contains(item) {
                    acc.remove(item)
                } else {
                    acc.insert(item)
                }
                return acc
            }
            // ok, have everything selected on the start
            .startWith(Set(initialSelectedProducts))
            .asDriver(onErrorJustReturn: Set())

        self.submit = submitSignal
            .asObservable()
            .withLatestFrom(self.state)
            .asDriver(onErrorJustReturn: Set())
    }
}
