import UIKit
import RxSwift
import RxCocoa

enum HomeMachineListType {
    case recommend
    case all
    case other
}

class HomeRecommendViewModel: PaginationViewModel<HomeMachine> {
    // 头部请求
    var requestMainPage = PublishSubject<Void>()
    var recommendHeadEnvelope = PublishSubject<HomeRecommendHeadEnvelope>()

    // 专题换一换请求
    var requestNextTheme = PublishSubject<HomeTheme>()
    var hotThemeEnvelope = PublishSubject<HomeTheme>()

    override init() {
        super.init()

        // 请求推荐头部数据
        let mainPageRequest = requestMainPage
            .flatMapLatest {
                AppEnvironment.current.apiService.getHomeMainPage().materialize()
            }
            .share(replay: 1)

        // 保存头部数据
        mainPageRequest.elements()
            .bind(to: recommendHeadEnvelope)
            .disposed(by: disposeBag)

        // 请求机台列表数据
        let machineListResponse = request.asObserver()
            .flatMapLatest { page in
                AppEnvironment.current.apiService.getHomeMachineList(type: nil, tagId: nil, sourceType: "LAST_USED", page: page).materialize()
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

        // 请求换一换专题数据
        let nextThemeRequest = requestNextTheme
            .filter { $0.nextParams != nil }
            .filter { $0.nextParams!.machineIds != nil }
            .filter { $0.nextParams!.limit != nil }
            .filter { $0.nextParams!.machineTopicId != nil }
            .flatMapLatest { theme in
                AppEnvironment.current.apiService.getChangeThemeMachineList(nextParams: theme.nextParams!).materialize()
            }
            .share(replay: 1)

        // 保存换一换专题数据
        nextThemeRequest.elements()
            .bind(to: hotThemeEnvelope)
            .disposed(by: disposeBag)
    }
}

import Curry
import Runes
import Argo

// MARK: - 首页机台列表
public struct HomeMachineListEnvelope {
    var machines: [HomeMachine]
    var type: String
    var isEnd: String
}

extension HomeMachineListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachineListEnvelope> {
        return curry(HomeMachineListEnvelope.init)
            <^> json <|| "machines"
            <*> json <| "type"
            <*> json <| "isEnd"
    }
}

// MARK: - 首页推荐头部
/// 首页专题视图类型
enum HomeHeadSubViewStyle: String {
    case special = "SPECIAL" // 上新
    case list = "LIST" // 推荐
    case cover = "COVER" // 专题
    case banner = "BANNER" // 广告
}

/// 上新专题视图的类型(顺时钟排序)
enum HomeNewSubViewStyle: String {
    case a = "A" // 上
    case b = "B" // 下 右上
    case c = "C" // 下 右下
    case d = "D" // 下 左
}

/// 上新专题视图的类型(顺时钟排序)
enum HomeMachineStatus: String {
    case idle = "0" // 空闲
    case game = "1" // 游戏中

    var small_image: String {
        return "home_machine_status_small_\(self.rawValue)"
    }
    
    var large_image: String {
        return "home_machine_status_large_\(self.rawValue)"
    }
}

/// 类型，1、2、3、4、5 分别表示 => 白、黄、绿、红、黑 机台
enum HomeMachineStyle: String {
    case white = "1"
    case yellow = "2"
    case green = "3"
    case red = "4"
    case black = "5"

    var image: String {
        return "home_machine_\(self.rawValue)"
    }
}

// 首页推荐头部数据
public struct HomeRecommendHeadEnvelope {
    var bannerList: [HomeBanner]

    var mainPageIconList: [HomeIcon]

    var machineTopicList: [HomeTheme]
}

/// Banner
public struct HomeBanner {
    /// ID
    var bannerId: String
    /// 跳转链接
    var action: String
    /// 名称
    var title: String
    /// 图片
    var picture: String
}

/// Icon列表
public struct HomeIcon {
    /// 名称
    var title: String
    /// 图片
    var image: String
    /// 跳转链接
    var action: String
}

/// 专题
public struct HomeTheme {
    ///
    var actionTitle: String?
    /// 图片
    var backgroudImage: String?
    /// 描述
    var description: String?
    /// 第几个
    var index: String?
    /// 机台列表
    var machineList: [HomeMachine]?
    /// 只有上新列表才会有该字段
    var styleInfo: [HomeStyleInfo]?
    /// ID
    var machineTopicId: String?
    /// 类型
    var sourceType: String?
    /// 标题
    var title: String?
    /// 跳转链接
    var topicLink: String?
    /// 样式
    var viewStyle: HomeHeadSubViewStyle?
    /// 换一换请求参数
    var nextParams: HomeNextParams?
}

public struct HomeNextParams {
    /// 限制个数
    var limit: String?
    ///
    var machineIds: [String]?
    ///
    var machineTopicId: String?
}

public struct HomeStyleInfo {
    var backgroundImage: String?
    var machineList: [HomeMachine]?
    var style: HomeNewSubViewStyle
}

/// 机台
public struct HomeMachine {
    /// 图片
    var icon: String
    /// 图片
    var image: String
    /// 机台物理 id
    var physicId: String
    /// 游戏价格
    var priceStr: String
    /// 原价
    var originalPrice: String?
    ///
    var productId: String
    /// 在线状态，0 表示空闲，1 表示游戏中
    var status: HomeMachineStatus
    /// 名称
    var title: String
    /// 类型，1、2、3、4、5 分别表示 => 白、黄、绿、红、黑 机台
    var type: HomeMachineStyle
    /// 领养人
    var owner: HomeMachineOwner?
    /// 机台副标题
    var subTitle: String?
    /// 机台标签
    var machineTags: [String]?
}

/// 领养人
public struct HomeMachineOwner {
    /// 昵称
    var nickname: String
    /// 头像
    var avatar: String
}

extension HomeRecommendHeadEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeRecommendHeadEnvelope> {
        return curry(HomeRecommendHeadEnvelope.init)
            <^> json <|| "bannerList"
            <*> json <|| "mainPageIconList"
            <*> json <|| "machineTopicList"
    }
}

extension HomeBanner: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeBanner> {
        return curry(HomeBanner.init)
            <^> json <| "bannerId"
            <*> json <| "action"
            <*> json <| "title"
            <*> json <| "picture"
    }
}

extension HomeIcon: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeIcon> {
        return curry(HomeIcon.init)
            <^> json <| "title"
            <*> json <| "image"
            <*> json <| "action"
    }
}

extension HomeTheme: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeTheme> {
        return curry(HomeTheme.init)
            <^> json <|? "actionTitle"
            <*> json <|? "backgroudImage"
            <*> json <|? "description"
            <*> json <|? "index"
            <*> json <||? "machineList"
            <*> json <||? "styleInfo"
            <*> json <|? "machineTopicId"
            <*> json <|? "sourceType"
            <*> json <|? "title"
            <*> json <|? "topicLink"
            <*> json <|? "viewStyle"
            <*> json <|? "nextParams"
    }
}

extension HomeStyleInfo: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeStyleInfo> {
        return curry(HomeStyleInfo.init)
            <^> json <|? "backgroundImage"
            <*> json <||? "machineList"
            <*> json <| "style"
    }
}

extension HomeNextParams: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeNextParams> {
        return curry(HomeNextParams.init)
            <^> json <|? "limit"
            <*> json <||? "machineIds"
            <*> json <|? "machineTopicId"
    }
}

extension HomeHeadSubViewStyle: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeHeadSubViewStyle> {
        switch json {
        case let .string(viewStyle):
            return pure(HomeHeadSubViewStyle(rawValue: viewStyle) ?? .banner)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

extension HomeNewSubViewStyle: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeNewSubViewStyle> {
        switch json {
        case let .string(style):
            return pure(HomeNewSubViewStyle(rawValue: style) ?? .a)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

extension HomeMachineStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachineStatus> {
        switch json {
        case let .string(type):
            return pure(HomeMachineStatus(rawValue: type) ?? .idle)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

extension HomeMachineStyle: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachineStyle> {
        switch json {
        case let .string(type):
            return pure(HomeMachineStyle(rawValue: type) ?? .white)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

extension HomeMachine: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachine> {
        return curry(HomeMachine.init)
            <^> json <| "icon"
            <*> json <| "image"
            <*> json <| "physicId"
            <*> json <| "priceStr"
            <*> json <|? "originalPrice"
            <*> json <| "productId"
            <*> json <| "status"
            <*> json <| "title"
            <*> json <| "type"
            <*> json <|? "owner"
            <*> json <|? "subTitle"
            <*> json <||? "machineTags"
    }
}

extension HomeMachineOwner: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<HomeMachineOwner> {
        return curry(HomeMachineOwner.init)
            <^> json <| "nickname"
            <*> json <| "avatar"
    }
}
