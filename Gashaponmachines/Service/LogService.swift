import Foundation
import Moya

public struct LogService {
    private let endpoint = "https://cn-shenzhen.log.aliyuncs.com"
    private let project = "xhtmobile"
    private let logstore = "ss_ios"
    private let accesskeyid = "123"
    private let accesskeysecret = "123"

    fileprivate var client: LogProducerClient!

    static let shared = LogService()

    init() {
        let config = LogProducerConfig(endpoint: endpoint, project: project, logstore: logstore, accessKeyID: accesskeyid, accessKeySecret: accesskeysecret)!
        client = LogProducerClient(logProducerConfig: config)
    }

    /// 上传HTTP请求Log
    func uploadHTTPRequestLog(path: String, params: [String: Any]) {

        if !AppEnvironment.isEnableLog { return }

        let log = Log()
        log.putContent("type", value: "httpRequest")
        if let uid = AppEnvironment.current.currentUser?.uid {
            log.putContent("uid", value: uid)
        }
        log.putContent("version", value: DeviceInfo.getAppVersion())
        log.putContent("host", value: Constants.kQUQQI_DOMAIN_URL)
        log.putContent("path", value: path)

        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        log.putContent("time", value: "\(timestamp)")

        var textParams = [String: Any]()
        textParams["params"] = params
        if let token = AppEnvironment.current.apiService.accessToken {
            textParams["token"] = token
        }

        do {
            let textData = try JSONSerialization.data(withJSONObject: textParams, options: [])
            if let jsonString = String(data: textData, encoding: .utf8) {
                log.putContent("text", value: jsonString)

            }
        } catch {
            QLog.error("网络请求Log解析失败")
        }

        client.add(log, flush: 1)
    }

    /// 上传HTTP响应Log
    func uploadHTTPResponseLog(response: Response, result: [String: Any]?) {

        if !AppEnvironment.isEnableLog { return }

        let log = Log()
        log.putContent("type", value: "httpResponse")
        if let uid = AppEnvironment.current.currentUser?.uid {
            log.putContent("uid", value: uid)
        }
        log.putContent("version", value: DeviceInfo.getAppVersion())
        log.putContent("host", value: Constants.kQUQQI_DOMAIN_URL)
        if let url = response.request?.url?.path {
            log.putContent("path", value: url)
        }

        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        log.putContent("time", value: "\(timestamp)")

        var textParams = [String: Any]()
        let clientBody = result?["clientBody"] as? [String: Any]
        let paramT = clientBody?["t"] as? String
        if let t = paramT {
            textParams["t"] = t
        }
        textParams["status"] = response.statusCode
        if let token = AppEnvironment.current.apiService.accessToken {
            textParams["token"] = token
        }

        do {
            let textData = try JSONSerialization.data(withJSONObject: textParams, options: [])
            if let jsonString = String(data: textData, encoding: .utf8) {
                log.putContent("text", value: jsonString)
            }
        } catch {
            QLog.error("网络请求Log解析失败")
        }

        client.add(log, flush: 1)
    }
}
