import Argo
import Curry
import Runes
import Moya
import RxSwift

public struct ErrorEnvelope {
    var code: String
    var msg: String
}

extension ErrorEnvelope: Swift.Error {}

extension ErrorEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ErrorEnvelope> {
        return curry(ErrorEnvelope.init)
        <^> json <| "code"
        <*> json <| "msg"
    }
}

extension ObservableType where Self.Element == Error {
    public func requestErrors() -> Observable<ErrorEnvelope> {
        return self.map { err -> ErrorEnvelope in
            if err is MoyaError {
                let moyaErr = err as! MoyaError
                return ErrorEnvelope(code: "8888", msg: moyaErr.errorDescription ?? "未知的 MoyaError")
            } else if err is ErrorEnvelope {
                return err as! ErrorEnvelope
            } else if err is DecodeError {
                let argoErr = err as! DecodeError
                return ErrorEnvelope(code: "8887", msg: "Argo DecodeError \(argoErr.description)")
            } else if err is GashaponmachinesError {
                let gasErr = err as! GashaponmachinesError
                return ErrorEnvelope(code: "\(gasErr.rawValue)", msg: gasErr.debugDescription)
            } else {
                return ErrorEnvelope(code: "8889", msg: "unknown Error")
            }
        }
    }
}
