public enum GashaponmachinesError: Int, Error, CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .failure:
            return "操作失败"
        case .success:
            return "操作成功"
        case .notLogin:
            return "用户登录凭证过期"
        case .serverError:
            return "服务器错误"
        case .requestFail:
            return "请求接口出错"
        case .unknownError:
            return "未知错误"
        case .mallNotEnoughBalance:
            return "蛋壳不足"
        case .mallProductNotEnough:
            return "兑换额度达到上限"
        case .uploadClientLog:
            return "上传日志失败"
        }
    }

    case failure = 1
    case success = 0
    case requestFail = 400
    case notLogin = 403
    case serverError = 500
    case unknownError = -1

    case mallNotEnoughBalance = 4200
    case mallProductNotEnough = 4340
    case uploadClientLog = 999
}
