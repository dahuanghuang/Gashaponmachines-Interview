import RxCocoa
import RxSwift

let PopMenuAdInfoUserDefaultKey = "PopMenuAdInfoUserDefaultKey"

public final class DanmakuService {

    weak var delegate: DanmakuReactable?

    weak var alertDelegate: PopMenuAdInfoReactable?

    static let shared = DanmakuService()

    // 行号数组
    var rows = [Int](repeating: 0, count: 10)

    fileprivate var cachedAdInfos: [PopMenuAdInfo] = []

    // 初始化
    func setup(adInfos: [PopMenuAdInfo]) {
        self.cachedAdInfos = adInfos
    }

    // 运营活动弹窗
    func showAlert(type: PopMenuAdInfo.ShowPage) {
        // 未登录不显示
        if AppEnvironment.current.apiService.accessToken == nil {
            return
        }

        // 在同一天不重复显示
        let time = AppEnvironment.userDefault.object(forKey: PopMenuAdInfoUserDefaultKey + "-" + type.rawValue)
        if let time = time as? Date, Calendar.current.isDate(Date(), inSameDayAs: time) {
            return
        }

        // 取出合适的弹窗展示
        let firstAdInfo = self.cachedAdInfos.filter { $0.showPage == type }.first
        guard let adInfo = firstAdInfo else {
            QLog.error("\(type.rawValue) not found, will ignore showing")
            return
        }

        self.alertDelegate?.attemptToShowAlert(adInfo: adInfo)

        AppEnvironment.userDefault.set(Date(), forKey: PopMenuAdInfoUserDefaultKey + "-" + type.rawValue)
        AppEnvironment.userDefault.synchronize()
    }

    func sendDanmaku(danmaku: UserDanmakuEnvelope) {

        if Setting.danmaku.isEnabled, let type = danmaku.type, type == .room {
            // 可以展示的行
            var enableRow = -1

            if !danmaku.level { // 优先级低的弹幕
                // 取出前两行
                let prefixRows = rows.prefix(upTo: 2)
                // 找到可用行
                for (index, value) in prefixRows.enumerated() {
                    if value == 0 {
                        enableRow = index
                        break
                    }
                }
            } else { // 优先级高的弹幕
                // 找出可用行
                for (index, value) in rows.enumerated() {
                    if value == 0 {
                        enableRow = index
                        break
                    }
                }
            }

            // 抛弃该弹幕
            if enableRow == -1 { return }

            // 该行已经被占用
            rows[enableRow] = 1

            let danmakuEnv = UserDanmakuEnvelope(picture: danmaku.picture, msg: "\(danmaku.msg)", avatar: danmaku.avatar, avatarFrame: danmaku.avatarFrame, type: danmaku.type, level: danmaku.level, index: enableRow)

            self.delegate?.attemptToSendDanmaku(danmaku: danmakuEnv)
        }
    }
}

protocol DanmakuReactable: class {
    func attemptToSendDanmaku(danmaku: UserDanmakuEnvelope)
}

protocol PopMenuAdInfoReactable: class {
    func attemptToShowAlert(adInfo: PopMenuAdInfo)
}
