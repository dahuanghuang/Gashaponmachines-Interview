import SocketIO
import Argo

private let secret = "123"

/// Socket NameSpace
///
/// - users:
private enum SocketNamespace: String {
    case users = "/users"
}

/// 主动向服务器发起事件
///
/// - userPlayGame: 玩游戏事件
/// - userJoinRoom: 进入房间事件
/// - userLeaveRoom: 离开房间事件
/// - userGetLastRoom: 获取最近游戏房间事件
enum SocketEmitEvent {

    // 普通扭蛋
    case userPlayGame(type: UserPlayGameEvent)
    case userJoinRoom(roomId: String)
    case userLeaveRoom(roomId: String)
    case userGetLastRoom

    // 一番赏
    case joinOnePieceRoom(onePieceTaskId: String)
    case leaveOnePieceRoom(onePieceTaskId: String)

    var eventIdentifier: String {
        switch self {
        case .userJoinRoom:       return "user-join-room"
        case .userLeaveRoom:      return "user-leave-room"
        case .userPlayGame:       return "user-play-game"
        case .userGetLastRoom:    return "user-get-lastRoom"

        case .joinOnePieceRoom:   return "joinOnePieceRoom"
        case .leaveOnePieceRoom:  return "leaveOnePieceRoom"
        }
    }
}

/// Socket 监听事件
public enum SocketListenEvent: CaseIterable {
    /// 当房间信息发生改变，服务端会广播此事件给所有用户
    case user_room_updated
    /// 断开连接
//    case reconnect
    /// 用户弹幕广播
    case user_live_commenting
    // 一番赏信息更新
    case onePieceRoomUpdate
    // 游戏状态变更
    case game_status_updated

    var eventIdentifier: String {
        switch self {
        case .user_room_updated:    return "user-room-updated"
//        case .reconnect:            return "reconnect"
        case .user_live_commenting: return "user-live-commenting"
        case .onePieceRoomUpdate:   return "onePieceRoomUpdate"
        case .game_status_updated:   return "SG_STATUS"
        }
    }
}

/// 游戏房间内监听的事件
public protocol SocketGameReactable: class {

    /// 广播房间信息更改
    func onUserRoomUpdated(envelope: UserRoomUpdatedEnvelope)

    /// 游戏状态更新
    func onGameStatusUpdated(envelope: GameStatusUpdatedEnvelope)
}

/// Socket 状态监听事件
public protocol SocketStatusReactable: class {

    /// 长链接断开连接
    func onReconnect()

    /// 长链接成功连接
    func onConnected()
}

extension SocketStatusReactable {

    /// 长链接断开连接
    func onReconnect() {}

    /// 长链接成功连接
    func onConnected() {}

    /// 更新首页机台的状态
    func onUserMachineNotice() {}

    /// 用户退出了游戏，但是可以快速返回最近的游戏
    func onUserLastRoom(envelope: UserLastRoomEnvelope) {}
}

public final class SocketService {

    /// 负责维护 Socket 状态
    public weak var statusHandler: SocketStatusReactable?

    /// 负责维护 游戏状态
    public weak var gameHandler: SocketGameReactable?

    /// 长链接状态
    public var status: SocketIOStatus? {
        return _userSocket?.status
    }

    /// 是否已连接
    ///
    public var isConnected: Bool {
        return status == .connected
    }

    static let shared = SocketService()

    private var _manager: SocketManager?

    private var _userSocket: SocketIOClient? {
        if let manager = self._manager {
            return manager.socket(forNamespace: SocketNamespace.users.rawValue)
        }
        return nil
    }

    /// 长链接地址
    private var socketURL: URL {
        switch AppEnvironment.current.stage {
        case .test: return URL(string: "https://cd.quqqi.com:17092/users")!
        case .stage, .release: return URL(string: "https://gs.quqqi.com/users")!
        }
    }

    /// 连接
    func connect(timeoutAfter: Double = 0, handler: (() -> Void)? = nil) {
        _userSocket?.connect(timeoutAfter: timeoutAfter, withHandler: handler)
    }

    /// 断开连接
    func disconnect() {
        _manager?.disconnect()
    }

    /// 时间监听
    ///
    /// - Parameters:
    ///   - event: 事件
    ///   - callback: 回调
    func onEvent(_ event: SocketListenEvent, callback: @escaping NormalCallback) {
        _userSocket?.on(event.eventIdentifier, callback: callback)
    }

    /// 普通事件
    ///
    /// - Parameters:
    ///   - event: 普通事件
    ///   - callback: callback
    func emitEvent(_ event: SocketEmitEvent, callback: @escaping AckCallback) {
        switch event {
        case .userGetLastRoom:
            _userSocket?.emitWithAck(event.eventIdentifier).timingOut(after: 1, callback: callback)
        case let .userLeaveRoom(roomId),
             let .userJoinRoom(roomId):
            _userSocket?.emitWithAck(event.eventIdentifier, roomId).timingOut(after: 1, callback: callback)
        case let .joinOnePieceRoom(onePieceTaskId),
             let .leaveOnePieceRoom(onePieceTaskId):
            _userSocket?.emitWithAck(event.eventIdentifier, onePieceTaskId).timingOut(after: 1, callback: callback)
        case .userPlayGame:
            return
        }

        BugTrackService<SocketEmitEvent>.writeEventToFile(event: event)
    }

    /// 用户玩游戏事件
    ///
    /// - Parameters:
    ///   - type: 游戏事件
    ///   - callback: callback
    func emitUserPlayGame(param: UserPlayGameEvent, ackCallback: @escaping AckCallback) {
        // 写入日志
        BugTrackService<SocketEmitEvent>.writeEventToFile(event: .userPlayGame(type: param))
        _userSocket?
            .emitWithAck(param.eventName, param.dictionaryRepresent)
            .timingOut(after: 1, callback: { data in
                guard let dic = data.first as? [String: Any] else {
                    return ackCallback(data)
                }
                BugTrackService<SocketEmitEvent>.writeCallBackToFile(eventName: param.eventName, eventDesc: param.eventDesc, dic: dic)
                ackCallback(data)
            })
    }

    // 心跳包事件
    func emitHeartPackage(eventId: String, ackCallback: @escaping AckCallback) {
        let params = ["ts": "\(Int(Date().timeIntervalSince1970))", "eventId": eventId]
        _userSocket?.emitWithAck("U_PING", params).timingOut(after: 1, callback: ackCallback)
    }

    /// 取消所有监听事件
    ///
    func removeAllHandlers() {
        _userSocket?.removeAllHandlers()
    }

    func setupWithSessionToken(sessionToken: String) {
        let timeInMs = String(format: "%.f", NSDate().timeIntervalSince1970 * 1000)
        guard let code = (sessionToken + "\(timeInMs)" + secret).md5 else {
            QLog.error("Code 出错")
            return
        }

        var config: SocketIOClientConfiguration = [.reconnects(true),
                                                   .reconnectAttempts(-1),
                                                   .forceWebsockets(true),
                                                   .compress,
                                                   .connectParams(["token": sessionToken,
                                                                   "time": timeInMs,
                                                                   "code": code])]

        #if DEBUG
        config.insert(.log(AppDelegate.enabledLog))
        #endif

        _manager = SocketManager(socketURL: socketURL, config: config)

        self.onEvent(.game_status_updated) { data, ack in
            guard let real = data.first, JSONSerialization.isValidJSONObject(real) else {
                QLog.error("SocketEvent: game_status_updated ==> Invalid json data returned from server.")
                return
            }

            if let j: Any = data.first, let envelope: GameStatusUpdatedEnvelope = decode(j) {
                self.gameHandler?.onGameStatusUpdated(envelope: envelope)
            } else {
                QLog.error("解析 game_status_updated 出错")
            }
        }

        self.onEvent(.user_room_updated) { data, ack in
            guard let real = data.first, JSONSerialization.isValidJSONObject(real) else {
                QLog.error("SocketEvent: user_room_updated ==> Invalid json data returned from server.")
                return
            }

            if let j: Any = data.first, let envelope: UserRoomUpdatedEnvelope = decode(j) {
                self.gameHandler?.onUserRoomUpdated(envelope: envelope)
            } else {
                QLog.error("解析 UserRoomUpdatedEnvelope 出错")
            }
        }

        self.onEvent(.user_live_commenting) { data, ack in

            guard let real = data.first, JSONSerialization.isValidJSONObject(real) else {
                QLog.error("SocketEvent: user_live_commenting ==> Invalid json data returned from server.")
                return
            }

            if let j: Any = data.first, let envelope: UserDanmakuEnvelope = decode(j) {
                DanmakuService.shared.sendDanmaku(danmaku: envelope)
            } else {
                QLog.error("解析 UserDanmakuEnvelope 出错")
            }
        }

        _userSocket?.on("disconnect") { data, ack in
            QLog.debug("Socket serverEvent disconnect")
        }

        _userSocket?.on("error") { data, ack in
            QLog.error("Socket serverEvent error")
        }

        _userSocket?.on(clientEvent: .connect) { data, ack in
            QLog.debug("------> Socket 客户端连接")
            self.statusHandler?.onConnected()
        }

        _userSocket?.on(clientEvent: .reconnect) { data, ack in
            QLog.debug("------> Socket 客户端重连")
            self.statusHandler?.onReconnect()
        }

        _userSocket?.on(clientEvent: .error) { data, ack in
            QLog.error("------> Socket 客户端连接错误")
            self.statusHandler?.onReconnect()
        }

        _userSocket?.on(clientEvent: .disconnect) { data, ack in
            QLog.debug("------> Socket 客户端连接断开连接")
//            self.statusHandler?.onReconnect()
        }

        _userSocket?.on(clientEvent: .reconnectAttempt) { data, ack in
            QLog.debug("------> Socket 客户端试图重新连接")
            self.statusHandler?.onReconnect()
        }

        _userSocket?.on(clientEvent: .statusChange) { data, ack in
            QLog.debug("------> Socket 客户端状态改变 -> \(data.first as! SocketIOStatus)")
        }
    }
}

/// 玩游戏的长链接事件
public enum UserPlayGameEvent {
    // 准备, 抢占机台
    case ready(roomId: String, eventId: String)
    // 暴击
    case crit(roomId: String, eventId: String, orderId: String, critMultiple: Int)
    // 立即开始
    case fire(roomId: String, eventId: String, orderId: String)
    // 再来一次
    case restart(roomId: String, eventId: String, orderId: String)
    // 不玩了
    case cancel(roomId: String, eventId: String, orderId: String)
    // 霸机充值
    case recharge(roomId: String, eventId: String, orderId: String)
    // 完成霸机充值
    case finishRecharge(roomId: String, eventId: String, orderId: String)
    // 取消霸机充值
    case cancelRecharge(roomId: String, eventId: String, orderId: String)

    // 事件名称
    var eventName: String {
        switch self {
        case .ready:          return "G_STRT"
        case .crit:           return "G_CRIT"
        case .fire:           return "G_FIRE"
        case .restart:        return "G_RST"
        case .cancel:         return "G_CXL"
        case .recharge:       return "G_RCHG"
        case .finishRecharge: return "G_FINRCHG"
        case .cancelRecharge: return "G_CXLRCHG"
        }
    }

    // 事件名称
    var eventDesc: String {
        switch self {
        case .ready:          return "抢占机台"
        case .crit:           return "暴击"
        case .fire:           return "立即开始"
        case .restart:        return "再来一次"
        case .cancel:         return "不玩了"
        case .recharge:       return "霸机充值"
        case .finishRecharge: return "完成霸机充值"
        case .cancelRecharge: return "取消霸机充值"
        }
    }

    // 传回服务器的参数字典
    var dictionaryRepresent: [String: Any] {
        var dic: [String: Any] = [:]

        switch self {
        case let .ready(roomId, eventId):
            dic["roomId"] = roomId
            dic["eventId"] = eventId
        case let .crit(roomId, eventId, orderId, critMultiple):
            dic["eventId"] = eventId
            dic["roomId"] = roomId
            dic["orderId"] = orderId
            dic["critMultiple"] = critMultiple
        case let .fire(roomId, eventId, orderId),
             let .restart(roomId, eventId, orderId),
             let .cancel(roomId, eventId, orderId),
             let .recharge(roomId, eventId, orderId),
             let .finishRecharge(roomId, eventId, orderId),
             let .cancelRecharge(roomId, eventId, orderId):

            dic["eventId"] = eventId
            dic["roomId"] = roomId
            dic["orderId"] = orderId
        }
        return dic
    }
}
