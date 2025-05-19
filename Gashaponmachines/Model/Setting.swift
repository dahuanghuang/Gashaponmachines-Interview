public enum Setting {
    case bgm
    case music
    case vibrate

	case danmaku
    case bindPhone
    case clearCache
    case aboutMe

    var cacheUserdefaultKey: String {
        return "com.Gashaponmachines.UserDefaults.\(self)Key"
    }

    var title: String {
        switch self {
        case .bgm: return "背景音乐"
        case .music: return "音效"
        case .vibrate: return "震动"

        case .danmaku: return "房间用户弹幕"
        case .bindPhone: return "手机号"
        case .clearCache: return "清除缓存"
        case .aboutMe: return "关于我们"
        }
    }

    public var isEnabled: Bool {
        get {
            switch self {
            case .bgm, .music, .vibrate, .danmaku: return AppEnvironment.userDefault.bool(forKey: cacheUserdefaultKey)
            default: return true
            }
        }
    }

    func setEnable(enable: Bool) {
        AppEnvironment.userDefault.set(enable, forKey: cacheUserdefaultKey)
        AppEnvironment.userDefault.synchronize()
    }

    static func _saveDefaultValuesAtFirstLaunch() {
        let lists: [Setting] = [.bgm, .music, .vibrate, .danmaku]
        lists.forEach { setting in
            if AppEnvironment.userDefault.value(forKey: setting.cacheUserdefaultKey) == nil {
                setting.setEnable(enable: true)
            }
        }
    }
}

let CONST_SETTINGS: [[Setting]] =
    [
        [
            Setting.bgm,
            Setting.music,
            Setting.vibrate
        ],
        [
            Setting.danmaku,
            Setting.bindPhone,
            Setting.clearCache,
            Setting.aboutMe
        ]
    ]

public struct SettingsEnvelope {
    var settings: [Setting]
}
