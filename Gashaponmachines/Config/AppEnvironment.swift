import Foundation
import Argo
import RxSwift

public struct AppEnvironment {

    // 保存整个 Environment 信息
    fileprivate static let environmentStorageKey = "com.ss.AppEnvironment.current"
    // 保存单一的 AccessToken
    fileprivate static let environmentAccessTokenStorageKey = "com.ss.AppEnvironment.accessToken"
    /// currentUser
    fileprivate static let userDefaultCurrentUserKey = "com.ss.UserDefault.currentUser"
    /// stage
    fileprivate static let userDefaultStageKey = "com.ss.UserDefault.stage"
    /// userId
    static let userDefaultUserIdKey = "com.ss.UserDefault.userId"

    // userDefault 实例
    internal static let userDefault = UserDefaults.standard

    // 当前环境
    public static var current: Environment! = Environment()

    /// 用户ID
    static var userId: String? {
        get {
            if let id = AppEnvironment.current.currentUser?._id {
                return id
            } else {
                return AppEnvironment.userDefault.value(forKey: userDefaultUserIdKey) as? String
            }
        }
    }

    static var reviewKeyWord: String {
        return "元气"
    }

    // 是否打开日志(默认关闭)
    public static var isEnableLog: Bool! {
        if let isLog = self.current.config?.isEnableLog {
            return isLog
        } else {
            return false
        }
    }

    // 是否有一番赏(默认打开)
    public static var isYfs: Bool! {
        if self.isReal {
            return false
        } else {
            if let isYfs = self.current.config?.isYfs {
                return isYfs
            } else {
                return true
            }
        }
    }
    
    // 是否有苹果登录
    public static var isAppleLogin: Bool! {
        if let isApple = self.current.config?.isAppleLogin {
            return isApple
        } else {
            return false
        }
    }

    // 是否为审核
    static var isReal: Bool {
        if WXApiManager.isWechatInstalled {
            // 装微信走默认逻辑
            if let config = AppEnvironment.current.config, config.isReal {
                return true
            } else {
                return false
            }
        } else {
            // 没装微信默认
            return true
        }
    }

    // 开发环境
    static let stage: Stage = AppEnvironment.current.stage

    // 单例
    static let shared = AppEnvironment()

    public static func login(sessionToken: String, user: User) {
        replaceCurrentEnvironment(
            apiService: AppEnvironment.current.apiService.login(sessionToken),
            currentUser: user
      	)
    }

    /// 注销用户 aka 退出登录
    public static func logout() {
        SocketService.shared.removeAllHandlers()
        SocketService.shared.disconnect()

        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.viewModel.logout.onNext(())

        let storage = AppEnvironment.current.cookieStorage
        storage.cookies?.forEach(storage.deleteCookie)
        replaceCurrentEnvironment(
            apiService: AppEnvironment.current.apiService.logout(),
            currentUser: nil
        )

        UIApplication.shared.keyWindow?.rootViewController = MainViewController()
    }

    public static func replaceCurrentEnvironment(_ env: Environment) {
        current = env
        saveEnvironment(environment: env)
    }

    public static func replaceCurrentEnvironment(
        stage: Stage                            = AppEnvironment.current.stage,
        apiDelayInterval: DispatchTimeInterval  = AppEnvironment.current.apiDelayInterval,
        config: Config?                         = AppEnvironment.current.config,
        apiService: ServiceType                 = AppEnvironment.current.apiService,
        cookieStorage: HTTPCookieStorage        = AppEnvironment.current.cookieStorage,
        currentUser: User?                      = AppEnvironment.current.currentUser,
        mainBundle: Bundle                      = AppEnvironment.current.mainBundle,
        debounceInterval: DispatchTimeInterval  = AppEnvironment.current.debounceInterval
        ) {

        let env = Environment(
            stage: stage,
            apiDelayInterval: apiDelayInterval,
            config: config,
            apiService: apiService,
            cookieStorage: cookieStorage,
            currentUser: currentUser,
            mainBundle: mainBundle,
            debounceInterval: debounceInterval
        )
        replaceCurrentEnvironment(env)
    }

    public static func pushEnvironment(
        stage: Stage                            = AppEnvironment.current.stage,
        apiDelayInterval: DispatchTimeInterval  = AppEnvironment.current.apiDelayInterval,
        config: Config?                         = AppEnvironment.current.config,
        apiService: ServiceType                 = AppEnvironment.current.apiService,
        cookieStorage: HTTPCookieStorage        = AppEnvironment.current.cookieStorage,
        currentUser: User?                      = AppEnvironment.current.currentUser,
        mainBundle: Bundle                      = AppEnvironment.current.mainBundle,
        debounceInterval: DispatchTimeInterval  = AppEnvironment.current.debounceInterval
        ) {

        let env = Environment(
            stage: stage,
            apiDelayInterval: apiDelayInterval,
            config: config,
            apiService: apiService,
            cookieStorage: cookieStorage,
            currentUser: currentUser,
            mainBundle: mainBundle,
            debounceInterval: debounceInterval
        )

        saveEnvironment(environment: env)
    }

    /// 从磁盘读取上次的环境配置
    public static func fromStorage() -> Environment {
        var apiService = current.apiService
        var currentUser: User?

        if let userToken = userDefault.value(forKey: AppEnvironment.environmentAccessTokenStorageKey) as? String {
            apiService = AppEnvironment.current.apiService.login(userToken)
            UserDefaults.standard.removeObject(forKey: AppEnvironment.environmentAccessTokenStorageKey)
        }

        if let userData = userDefault.object(forKey: AppEnvironment.userDefaultCurrentUserKey) as? Data, let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        } else {
            QLog.debug("CurrentUser 为空")
        }

        if let stageValue = userDefault.value(forKey: AppEnvironment.userDefaultStageKey) as? String,
            let stage = Stage(rawValue: stageValue) {
            return Environment(stage: stage,
                               apiService: apiService,
                               currentUser: currentUser
                               )
        } else {
            return Environment(apiService: apiService,
                               currentUser: currentUser
                               )
        }
    }

    /// 保存环境配置
    ///
    /// - Parameter env: 环境配置
    /// 保存currentUser, accessToken, stage
    private static func saveEnvironment(environment env: Environment = AppEnvironment.current) {

        #if DEBUG
            QLog.debug("ACCESSTOKEN SAVED TO KEYCHAIN - \(env.apiService.accessToken ?? "")")
        #endif
        if let currentUser = env.currentUser, let data = try? JSONEncoder().encode(currentUser) {
			userDefault.set(data, forKey: AppEnvironment.userDefaultCurrentUserKey)
        }

        userDefault.set(env.apiService.accessToken, forKey: AppEnvironment.environmentAccessTokenStorageKey)
        userDefault.set(env.stage.rawValue, forKey: AppEnvironment.userDefaultStageKey)
        userDefault.synchronize()
    }

    /// 更新 appInit 拉的配置
    /// - Parameter config: 配置
    public static func updateConfig(_ config: Config) {
        replaceCurrentEnvironment(config: config)
    }

    /// 切换 Stage 环境
    /// 因为切换环境，所以我们把本地的 sessionToken 去掉
    /// - Parameter stage: Stage
    public static func switchEnvironmentStage(_ stage: Stage) {
//        clearUserDefault()
        replaceCurrentEnvironment(stage: stage)
        logout()
    }
}

private func clearUserDefault() {
    let appDomain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: appDomain)
}
