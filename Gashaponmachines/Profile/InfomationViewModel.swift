import Foundation
import RxSwift
import RxCocoa

class InfomationViewModel: BaseViewModel {
    
    // 获取用户信息
    var viewWillAppearTrigger = PublishSubject<Void>()
    var personalInfoEnvelope = PublishSubject<PersonalInfoEnvelope>()
    
    // 获取上传图片Token
    var getUploadToken = PublishSubject<Int>()
    var getUploadTokenResp = PublishSubject<TokenAndKeysEnvelope>()
    
    // 更改用户信息
    var editUserInfo = PublishSubject<(String?, String?)>()
    var editUserInfoEnvelope = PublishSubject<ResultEnvelope>()
    
    // 注销账户
    var destroyAccountTrigger = PublishSubject<Void>()
    var destroyAccountEnvelope = PublishSubject<ResultEnvelope>()

    override init() {
        super.init()

        // 获取用户信息
        let personalInfoResponse = viewWillAppearTrigger.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.getPersonalInfo().materialize()
            }
            .share(replay: 1)

        personalInfoResponse.elements()
            .bind(to: personalInfoEnvelope)
            .disposed(by: disposeBag)
        
        // 获取上传的Token
        let uploadTokenResponse = getUploadToken
            .flatMapLatest { keyCount in
                AppEnvironment.current.apiService.getTokenAndKeys(keyCount: keyCount).materialize()
            }
            .share(replay: 1)

        uploadTokenResponse.elements()
            .bind(to: getUploadTokenResp)
            .disposed(by: disposeBag)
        
        // 更改名称
        let editUserInfoResponse = editUserInfo.asObservable()
            .flatMapLatest { (username, imageKey) in
                AppEnvironment.current.apiService.changeUserNicknameOrAvatar(username: username, imageKey: imageKey).materialize()
            }
            .share(replay: 1)

        editUserInfoResponse.elements()
            .bind(to: editUserInfoEnvelope)
            .disposed(by: disposeBag)
        
        // 注销账号
        let destroyAccountResponse = destroyAccountTrigger.asObservable()
            .flatMapLatest { _ in
                AppEnvironment.current.apiService.destroyAccount().materialize()
            }
            .share(replay: 1)

        destroyAccountResponse.elements()
            .bind(to: destroyAccountEnvelope)
            .disposed(by: disposeBag)
        
        // 错误
        Observable.merge(
            personalInfoResponse.errors(),
            uploadTokenResponse.errors(),
            editUserInfoResponse.errors(),
            destroyAccountResponse.errors()
        ).requestErrors().bind(to: error).disposed(by: disposeBag)
            
    }
}

import Argo
import Curry
import Runes

public struct PersonalInfoEnvelope: Codable {
    var avatar: String
    var uid: String
    var nickname: String
    var leftChangeAvatarTimes: Int // 剩余更换头像次数
    var leftRenameTimes: Int // 剩余更名次数
    var enableDestroyAccount: Bool // 能否更改账号
}

extension PersonalInfoEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PersonalInfoEnvelope> {
        return curry(PersonalInfoEnvelope.init)
            <^> json <| "avatar"
            <*> json <| "uid"
            <*> json <| "nickname"
            <*> (json <| "leftChangeAvatarTimes" <|> (json <| "leftChangeAvatarTimes").map(String.toInt))
            <*> (json <| "leftRenameTimes" <|> (json <| "leftRenameTimes").map(String.toInt))
            <*> (json <| "enableDestroyAccount" <|> (json <| "enableDestroyAccount").map(String.toBool))
    }
}
