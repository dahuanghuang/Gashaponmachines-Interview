import Qiniu
import SwiftDate

/// 该协议用于写入日志并上传至服务器
protocol Trackable {

    /// 保存到磁盘的文件名
    static var fileName: String { get }

    /// 日志记录的内容
    var record: String { get }

    static var expiredDays: Int { get }

    associatedtype TrackItem
}

enum UserTrackEvent: Trackable {

    case BadNetwork
    case PlayAgain
    case NotPlay
    case OccupyRecharge
    case CancelOccupy
    case ComfirmCancelOccupy
    case BackOccupyRecharge
    case RechargeSucees
    case RechargeError
    case Recharge

    case ClickCritButton
    case ShowInfo
    case HiddenInfo
    case ShowAction
    case HiddenAction
    case ActionConfirm(critCount: Int)
    case ActionCancle

    var desc: String {
        switch self {
        case .BadNetwork:
            return "显示网络断开连接弹窗, 退出房间"
        case .PlayAgain:
            return "游戏结束弹窗, 点击再来一次"
        case .NotPlay:
            return "游戏结束弹窗, 点击不玩了"
        case .OccupyRecharge:
            return "点击霸机界面底部充值按钮"
        case .CancelOccupy:
            return "点击霸机界面右上角x按钮"
        case .ComfirmCancelOccupy:
            return "取消霸机二次确认弹窗, 点击取消霸机按钮"
        case .BackOccupyRecharge:
            return "取消霸机二次确认弹窗, 点击返回充值按钮"
        case .RechargeSucees:
            return "霸机充值结果确认弹窗, 点击支付成功按钮"
        case .RechargeError:
            return "霸机充值结果确认弹窗, 点击支付失败按钮"
        case .Recharge:
            return "展示我的充值界面"
        case .ClickCritButton:
            return "点击暴击按钮"
        case .ShowInfo:
            return "展示暴击Info弹窗"
        case .HiddenInfo:
            return "隐藏暴击Info弹窗"
        case .ShowAction:
            return "展示暴击Action弹窗"
        case .HiddenAction:
            return "隐藏暴击Action弹窗"
        case let .ActionConfirm(critCount):
            return "点击暴击Action弹窗确认按钮, 暴击次数为\(critCount)"
        case .ActionCancle:
            return "点击暴击Action弹窗取消按钮"
        }
    }

    static var expiredDays: Int {
        return 3
    }

    typealias TrackItem = UserTrackEvent

    static var fileName: String {
        return "client_log.txt"
    }

    var record: String {
        var prefix =  "{\"timestamp\":\(Date().timestampNow())"
        prefix += ",\"eventName\":\(self.desc)"

        prefix += ",\"operationType\":用户UI事件"

        prefix += "}\n"
        return prefix
    }
}

extension SocketEmitEvent: Trackable {

    static var expiredDays: Int {
        return 3
    }

    typealias TrackItem = SocketEmitEvent

    static var fileName: String {
        return "client_log.txt"
    }

    var record: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss:SSS"
        let now = dateFormatter.string(from: Date())

        switch self {
        case let .userPlayGame(type):

            var prefix = "{\"timestamp\":\(now.description),\"eventName\":\(type.eventName),\"eventDesc\":\(type.eventDesc)"

            switch type {
            case let .ready(roomId, eventId):
                prefix += ",\"eventId\":\(eventId.description),\"roomId\":\(roomId.description)"
            case let .fire(roomId, eventId, orderId),
                 let .cancel(roomId, eventId, orderId),
                 let .restart(roomId, eventId, orderId),
                 let .recharge(roomId, eventId, orderId),
                 let .finishRecharge(roomId, eventId, orderId),
                 let .cancelRecharge(roomId, eventId, orderId):
                prefix += ",\"eventId\":\(eventId.description),\"roomId\":\(roomId.description),\"orderId\":\(orderId.description)"
            case let .crit(roomId, eventId, orderId, critMultiple):
                prefix += ",\"eventId\":\(eventId.description),\"roomId\":\(roomId.description),\"orderId\":\(orderId.description),\"critMultiple\":\(critMultiple)"
            }
            prefix += ",\"operationType\":用户socket事件"
            prefix += "}\n"
            return prefix

        case let .userJoinRoom(roomId):
            return "{\"timestamp\":\(now.description),\"eventName\":\(self.eventIdentifier),\"roomId\":\(roomId.description)},\"operationType\":用户socket事件\n"
        case let .userLeaveRoom(roomId):
            return "{\"timestamp\":\(now.description),\"eventName\":\(self.eventIdentifier),\"roomId\":\(roomId.description)},\"operationType\":用户socket事件\n"
        case .userGetLastRoom:
            return "{\"timestamp\":\(now.description),\"eventName\":\(self.eventIdentifier)},\"operationType\":用户socket事件\n"
        case let .joinOnePieceRoom(onePieceTaskId):
            return "{\"timestamp\":\(now.description),\"eventName\":\(self.eventIdentifier),\"onePieceTaskId\":\(onePieceTaskId.description)},\"operationType\":用户socket事件\n"
        case let .leaveOnePieceRoom(onePieceTaskId):
            return "{\"timestamp\":\(now.description),\"eventName\":\(self.eventIdentifier),\"onePieceTaskId\":\(onePieceTaskId.description)},\"operationType\":用户socket事件\n"
        }
    }
}

class BugTrackService<TrackItem: Trackable> {

    static var lastCleanDateUserDefaultKey: String {
        return "BugTrackService.lastUploadDate.userDefault.key.\(TrackItem.fileName)"
    }
    static var fileURL: URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(TrackItem.fileName)
            return fileURL
        }
        return nil
    }

    static var fileData: Data? {
        if let fileURL = fileURL {
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                return text.data(using: .utf8)! as Data
            } catch {/* error handling here */}
        }
        return nil
    }

    static func writeError(dic: [String: Any]) {
        if let fileURL = fileURL {
            do {
                var prefix = "!!! Error !!! "
                prefix += dic.description
                prefix += "\n"
                try prefix.appendToURL(fileURL: fileURL)
            } catch {/* error handling here */}
        }
    }

    static func writeStringToFile(str: String) throws {
        if let fileURL = fileURL {
            do {
                try str.appendToURL(fileURL: fileURL)
            } catch {/* error handling here */}
        }
    }

    static func writeEventToFile(event: TrackItem) {
        do {
            try writeStringToFile(str: event.record)
        } catch {/* error handling here */}
    }

    /// 写入分隔符
    static func writeDelimiter() {
        let prefix = "&&&\n"
        do {
            try writeStringToFile(str: prefix)
        } catch {/* error handling here */}
    }

    static func writeCallBackToFile(eventName: String, eventDesc: String, dic: [String: Any]) {

//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
//        let now = dateFormatter.string(from: Date())
        var prefix = "{\"timestamp\":\(Date().timestampNow()),\"eventName\":\(eventName),\"eventDesc\":\(eventDesc)"

        if let code = dic["code"] as? Int {
            prefix += ",\"code\":\(String(code))"
        }
        if let msg = dic["msg"] as? String {
            prefix += ",\"msg\":\(msg)"
        }
        if let jobId = dic["jobId"] as? String {
            prefix += ",\"jobId\":\(jobId)"
        }
        if let roomId = dic["roomId"] as? String {
            prefix += ",\"roomId\":\(roomId)"
        }
        if let roomId = dic["orderId"] as? String {
            prefix += ",\"orderId\":\(roomId)"
        }

        if let data = dic["data"] as? [String: Any] {
            if let eventId = data["eventId"] as? String {
                prefix += ",\"eventId\":\(eventId)"
            }
            if let ts = data["ts"] as? Double,
                let time = String.time(timestamp: ts) {
                prefix += ",\"serverSendTime\":\(time)"
            }
        }

        prefix += ",\"operationType\":服务器返回结果事件"
        prefix += "}\n"
        do {
            try writeStringToFile(str: prefix)
        } catch {/* error handling here */}
    }

    static func clearIfExpired() {

        if let lastCleanDate = AppEnvironment.userDefault.object(forKey: lastCleanDateUserDefaultKey) as? Date {
            // 超过3天
            if let daysbetween = (Date() - lastCleanDate).day, daysbetween > TrackItem.expiredDays, let fileURL = fileURL {

                // 写入分隔符
                self.writeDelimiter()

                do {
                    let text = try String(contentsOf: fileURL, encoding: .utf8)
                    let separateStrs = text.components(separatedBy: "&&&")
                    // "前3天数据", "后3天数据", "\n"
                    if separateStrs.count == 3 {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch let error {
                            QLog.error("Error: \(error.localizedDescription)")
                        }

                        let newText = separateStrs[1] + "&&&\n"

                        do {
                            // 取后3天数据存储
                            try writeStringToFile(str: newText)
                        } catch {/* error handling here */}
                    }
                } catch {/* error handling here */}

                // 保存时间
                AppEnvironment.userDefault.set(Date(), forKey: lastCleanDateUserDefaultKey)
                AppEnvironment.userDefault.synchronize()
            }
        } else { // 第一次存储
            // 保存时间
            AppEnvironment.userDefault.set(Date(), forKey: lastCleanDateUserDefaultKey)
            AppEnvironment.userDefault.synchronize()
        }
    }
}

fileprivate extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

fileprivate extension Data {
    // 在文本最后添加一行
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: fileURL, options: .atomic)
        }
    }

    // 在文本最前面添加一行
    func prepend(fileURL: URL, to outputHandle: FileHandle) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            while true {
                let data = fileHandle.readData(ofLength: 4096)
                if data.isEmpty {
                    break
                } else {
                    outputHandle.write(data)
                }
            }
        }
    }
}
