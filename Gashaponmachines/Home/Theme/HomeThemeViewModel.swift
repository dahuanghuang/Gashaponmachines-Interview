import UIKit
import RxSwift
import RxCocoa

class HomeThemeViewModel: BaseViewModel {
    var requestThemeList = PublishSubject<Void>()
    var themeListEnvelope = PublishSubject<HomeThemeListEnvelope>()

    init(themeId: String) {
        super.init()

        let request = requestThemeList
           .flatMapLatest {
            AppEnvironment.current.apiService.getThemeMachineList(themeId: themeId).materialize()
           }
           .share(replay: 1)

        request.elements()
        .bind(to: themeListEnvelope)
        .disposed(by: disposeBag)
    }
}

import Curry
import Runes
import Argo

public struct HomeThemeListEnvelope {
    /// 专题信息
    var machineTopicInfo: ThemeInfo
    /// 机台列表
    var machines: [HomeMachine]
}

public struct ThemeInfo {
    ///
    var actionTitle: String?
    /// 图片
    var backgroudImage: String
    /// 描述
    var description: String
    /// 第几个
    var index: String
    /// ID
    var machineTopicId: String
    /// 类型
    var sourceType: String
    /// 标题
    var title: String
    /// 跳转链接
    var topicLink: String?
    /// 样式
    var viewStyle: String
}

extension HomeThemeListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeThemeListEnvelope> {
        return curry(HomeThemeListEnvelope.init)
            <^> json <| "machineTopicInfo"
            <*> json <|| "machines"
    }
}

extension ThemeInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ThemeInfo> {
        return curry(ThemeInfo.init)
            <^> json <|? "actionTitle"
            <*> json <| "backgroudImage"
            <*> json <| "description"
            <*> json <| "index"
            <*> json <| "machineTopicId"
            <*> json <| "sourceType"
            <*> json <| "title"
            <*> json <|? "topicLink"
            <*> json <| "viewStyle"
    }
}
