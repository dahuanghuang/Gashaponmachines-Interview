import Foundation

class TestViewController: BaseViewController {

    fileprivate var client: LogProducerClient!

    fileprivate let endpoint = "https://cn-shenzhen.log.aliyuncs.com"
    fileprivate let project = "xhtmobile"
    fileprivate let logstore = "ss_ios"
    fileprivate let accesskeyid = "IlYfrRJCcDIOhDki"
    fileprivate let accesskeysecret = "kYd0PegeAVZ0WatEwiC6MFaa2UiJrp"

    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let config = LogProducerConfig(endpoint:endpoint, project:project, logstore:logstore, accessKeyID:accesskeyid, accessKeySecret:accesskeysecret)!
//
//        client = LogProducerClient(logProducerConfig:config)

        let connectBtn = UIButton()
        connectBtn.addTarget(self, action: #selector(sendLog), for: .touchUpInside)
        connectBtn.backgroundColor = .black
        connectBtn.setTitle("发送日志", for: .normal)
        view.addSubview(connectBtn)
        connectBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
    }

    @objc func sendLog() {
//        let log = Log()
//        log.putContent("我的生日", value: "十九点半")
//        client.add(log)

//        LogService.shared.sendNetworkLog(path: "", params: [:])
    }
}

/* Socket 案例
class TestViewController: BaseViewController {
    
    let tf = UITextField()

    // MARK: - socketTest
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TestSocketService.shared.setup()
        
        tf.backgroundColor = .red
        view.addSubview(tf)
        tf.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(100)
        }
        
        let connectBtn = UIButton()
        connectBtn.addTarget(self, action: #selector(connect), for: .touchUpInside)
        connectBtn.backgroundColor = .black
        connectBtn.setTitle("开始连接", for: .normal)
        view.addSubview(connectBtn)
        connectBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        let disconnectBtn = UIButton()
        disconnectBtn.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
        disconnectBtn.backgroundColor = .black
        disconnectBtn.setTitle("断开连接", for: .normal)
        view.addSubview(disconnectBtn)
        disconnectBtn.snp.makeConstraints { make in
            make.top.equalTo(connectBtn.snp.bottom).offset(10)
            make.centerX.equalTo(connectBtn)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        let sendBtn = UIButton()
        sendBtn.addTarget(self, action: #selector(send), for: .touchUpInside)
        sendBtn.backgroundColor = .black
        sendBtn.setTitle("发送", for: .normal)
        view.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.top.equalTo(disconnectBtn.snp.bottom).offset(10)
            make.centerX.equalTo(disconnectBtn)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
    }
    
    @objc func connect() {
        print("--------> : \(Int(Date().timeIntervalSince1970))")
//        TestSocketService.shared.connect()
    }
    
    @objc func disconnect() {
        TestSocketService.shared.disconnect()
    }
    
    @objc func send() {
        TestSocketService.shared.sendMessage()
    }
}


import SocketIO

/// Socket NameSpace
///
/// - users:
private enum SocketNamespace: String {
    case users = "/users"
}

public final class TestSocketService {

    static let shared = TestSocketService()

    private var _manager: SocketManager?

    private var _userSocket: SocketIOClient? {
        if let manager = self._manager {
            return manager.socket(forNamespace: SocketNamespace.users.rawValue)
        }
        return nil
    }

    /// 长链接地址
    private var socketURL: URL {
        return URL(string: "http://192.168.1.150:6969")!
    }

    /// 连接
    func connect() {
        _userSocket?.connect()
    }

    /// 断开连接
    func disconnect() {
        _userSocket?.disconnect()
    }
    
    func sendMessage() {
        _userSocket?.emit("ni hao a")
    }

    /// 发送事件
    func emitEvent(_ event: String, callback: @escaping AckCallback) {
        _userSocket?.emitWithAck(event).timingOut(after: 1, callback: callback)
    }

    func setup() {

//        let config: SocketIOClientConfiguration = [.reconnects(true),
//                                                   .reconnectAttempts(-1),
////                                                   .forceWebsockets(true),
//                                                   .compress]

        _manager = SocketManager(socketURL: socketURL)

        _userSocket?.on("disconnect") { data, ack in
            QLog.debug("Socket serverEvent disconnect")
        }

        _userSocket?.on("error") { data, ack in
            QLog.error("Socket serverEvent error")
        }

        _userSocket?.on(clientEvent: .connect) { data, ack in
            QLog.debug("------>>> Socket 客户端连接")
        }

        _userSocket?.on(clientEvent: .reconnect) { data, ack in
            QLog.debug("------>>> Socket 客户端重连")
        }

        _userSocket?.on(clientEvent: .error) { data, ack in
            QLog.error("------>>> Socket 客户端连接错误")
        }

        _userSocket?.on(clientEvent: .disconnect) { data, ack in
            QLog.debug("------>>> Socket 客户端连接断开连接")
        }

        _userSocket?.on(clientEvent: .reconnectAttempt) { data, ack in
            QLog.debug("------>>> Socket 客户端试图重新连接")
        }

        _userSocket?.on(clientEvent: .statusChange) { data, ack in
            QLog.debug("------>>> Socket 客户端状态改变 -> \(data.first as! SocketIOStatus)")
        }
    }
}
 */
