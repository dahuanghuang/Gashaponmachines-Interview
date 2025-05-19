import CocoaLumberjack

struct QLog {

    static let shared = QLog()

    static let logShared: DDLogger = DDTTYLogger.sharedInstance

    // 日志写到本地文件类
    private static var fileLogger: DDFileLogger!

    // 定义打印级别
//    private static var ddLogLevel: DDLogLevel = .verbose

    static func setupWithLogLevel(_ level: DDLogLevel) {

        let fl: DDFileLogger = DDFileLogger()
        // 最大文件数量，每次启动都会启用新的日志文件，因此设高一点
        fl.logFileManager.maximumNumberOfLogFiles = 50
        // 文件保存时间，保存48小时
        fl.rollingFrequency = TimeInterval(60*60*24)
        // 不重复使用同一个文件记录日志
        fl.doNotReuseLogFiles = true

        DDLog.add(fl, with: level)
        DDLog.add(DDTTYLogger.sharedInstance, with: level)

        self.fileLogger = fl
    }

    /// 读取日志文件
    /// - Returns: 返回历史日志
    static func readFileLog() -> [String] {
        let fileInfos = self.fileLogger.logFileManager.sortedLogFileInfos
        var logInfos = [String]()
        if let infos = fileInfos {
            infos.forEach({ (info) in
                do {
                    let content = try String(contentsOfFile: info.filePath, encoding: .utf8)
                    logInfos.append(content)
                } catch {
                    QLog.error("读取日志文件失败")
                }
            })
        }
        return logInfos
    }

    static func error(_ message: String?, function: String = #function, fileLine: Int = #line, file: String = #file) {
        let fileName = (file as NSString).lastPathComponent
        let error = "\n❌error: \(message ?? "value is empty") \n❌function: \(function) \n❌fileLine: \(fileName) - \(fileLine)"
        DDLogError(error)
    }

    static func debug(_ message: String?, function: String = #function, fileLine: Int = #line, file: String = #file) {
        let fileName = (file as NSString).lastPathComponent
        let debug = "\n🔷debug: \(message ?? "value is empty") \n🔷function: \(function) \n🔷fileLine: \(fileName) - \(fileLine)"
        DDLogDebug(debug)
    }

    static func warning(_ message: String?, function: String = #function, fileLine: Int = #line, file: String = #file) {
        let fileName = (file as NSString).lastPathComponent
        let warn = "\n⚠️warn: \(message ?? "value is empty") \n⚠️function: \(function) \n⚠️fileLine: \(fileName) - \(fileLine)"
        DDLogWarn(warn)
    }

    static func verbose(_ message: String?, function: String = #function, fileLine: Int = #line, file: String = #file) {
        let fileName = (#file as NSString).lastPathComponent
        let verbose = "\n♦️verbose: \(message ?? "value is empty") \n♦️function: \(function) \n♦️fileLine: \(fileName) - \(fileLine)"
        DDLogVerbose(verbose)
    }

    static func info(_ message: String?, function: String = #function, fileLine: Int = #line, file: String = #file) {
        let fileName = (#file as NSString).lastPathComponent
        let info = "\n📚info: \(message ?? "value is empty") \n📚function: \(function) \n📚fileLine: \(fileName) - \(fileLine)"
        DDLogInfo(info)
    }

    /// 转换LogLevel为DDLogLevel
//    private static func convertToDDLogLevel(level: LogLevel) -> DDLogLevel {
//        switch level {
//        case .Off: return .off
//        case .Error: return .error
//        case .Warning: return .warning
//        case .Info: return .info
//        case .Debug: return .debug
//        case .Verbose: return .verbose
//        case .All: return .all
//        }
//    }
}

// 打印级别枚举, 主要用于隔离DDLog框架的引用
// enum LogLevel: Int {
//    /* 不进行打印 */
//    case Off = 0
//    /* 只打印 Error 日志 */
//    case Error = 1
//    /* 打印 Error, Warning 日志 */
//    case Warning = 2
//    /* 打印 Error, warning, info 日志 */
//    case Info = 3
//    /* 打印 Error, warning, info, debug 日志 */
//    case Debug = 4
//    /* 打印 Error, warning, info, debug, verbose 日志 */
//    case Verbose = 5
//    /* 打印所有日志 */
//    case All = 6
// }
