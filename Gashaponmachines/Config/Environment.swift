import Foundation
import UIKit

public struct Environment {

    public let stage: Stage

    public let config: Config?

    public var apiService: ServiceType

    public let cookieStorage: HTTPCookieStorage

    public let currentUser: User?

    public let mainBundle: Bundle

    public let debounceInterval: DispatchTimeInterval

    /// The amount of time to delay API requests by. Used primarily for testing. Default value is `0.0`.
    public let apiDelayInterval: DispatchTimeInterval

    public init(
        // 默认环境为 release
        stage: Stage = .release,
        apiDelayInterval: DispatchTimeInterval = .seconds(0),
        config: Config? = nil,
        apiService: ServiceType = APIService(),
        cookieStorage: HTTPCookieStorage = HTTPCookieStorage.shared,
        currentUser: User? = nil,
        mainBundle: Bundle = Bundle.main,
        debounceInterval: DispatchTimeInterval = .milliseconds(300),
        connectableViaCelluar: Bool = true) {
        self.stage = stage
        self.apiDelayInterval = apiDelayInterval
        self.config = config
        self.apiService = apiService
        self.cookieStorage = cookieStorage
        self.currentUser = currentUser
        self.mainBundle = mainBundle
        self.debounceInterval = debounceInterval
    }
}
