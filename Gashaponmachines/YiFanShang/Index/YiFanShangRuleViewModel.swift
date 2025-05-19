import RxSwift
import RxCocoa

class YiFanShangRuleViewModel: BaseViewModel {
    
    var requestRules = PublishSubject<Void>()
    let rulesEnvelope = PublishSubject<YiFanShangRuleListEnvelope>()

    override init() {
        super.init()
        
        let ruleResponse = requestRules
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getOnePieceRules().materialize()
            }
            .share(replay: 1)
        
        ruleResponse.elements()
            .bind(to: rulesEnvelope)
            .disposed(by: disposeBag)
        
        ruleResponse.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}

