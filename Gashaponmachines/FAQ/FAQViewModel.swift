import RxCocoa
import RxSwift

class FAQViewModel: BaseViewModel {
    
    var requestFaqs = PublishSubject<Void>()
    let faqEnvelope = PublishSubject<FAQEnvelope>()

    override init() {
        super.init()
        
        let response = requestFaqs
            .flatMapLatest {
                AppEnvironment.current.apiService.getFaq().materialize()
            }
            .share(replay: 1)

        response.elements()
            .bind(to: faqEnvelope)
            .disposed(by: disposeBag)
    }
}
