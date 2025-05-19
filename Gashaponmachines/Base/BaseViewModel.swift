import RxCocoa
import RxSwift

open class BaseViewModel {

    open var error = PublishSubject<ErrorEnvelope>()

    var disposeBag = DisposeBag()

    init() {}
}
