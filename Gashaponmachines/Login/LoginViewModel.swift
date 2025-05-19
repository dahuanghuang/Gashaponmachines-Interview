import RxCocoa
import RxSwift
import RxSwiftExt

class LoginViewModel: BaseViewModel {
    // 微信登录请求
    var wechatRequest = PublishSubject<String>()
    var wechatLoginEnvelope = PublishSubject<LoginEnvelope>()
    
    // 苹果登录请求
    var appleRequest = PublishSubject<[String: String]>()
    var appleLoginEnvelope = PublishSubject<LoginEnvelope>()
    
//    // 模拟微信登录-手机模拟器
//    var mockLoginEnvelope = PublishSubject<LoginEnvelope>()

    override init() {
        super.init()
        
        // 微信登录
        let wechatResponse = wechatRequest.asObservable().flatMapLatest { code in
                AppEnvironment.current.apiService.loginByOAuth(OAuthType: "wechat", installationId: PushService.deviceId, code: code, identityToken: nil, authorizationCode: nil, fullName: nil, appleUserId: nil).materialize()
            }
            .share(replay: 1)

        wechatResponse.elements()
            .bind(to: wechatLoginEnvelope)
            .disposed(by: disposeBag)
        
        // apple登录
        let appleResponse = appleRequest.asObservable().flatMapLatest { cre in
            AppEnvironment.current.apiService.loginByOAuth(OAuthType: "apple", installationId: PushService.deviceId, code: nil, identityToken: cre["token"], authorizationCode: cre["code"], fullName: cre["name"], appleUserId: cre["id"]).materialize()
        }.share(replay: 1)
        
        appleResponse.elements()
            .bind(to: appleLoginEnvelope)
            .disposed(by: disposeBag)
        
        Observable.merge(wechatResponse.errors(), appleResponse.errors())
//        wechatResponse.errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
