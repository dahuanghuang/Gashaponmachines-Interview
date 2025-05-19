import Argo
import Runes
import Curry
import RxSwift
import RxSwiftExt

public struct ResultEnvelope {
    var code: String
    var msg: String
}

extension ResultEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ResultEnvelope> {
        return curry(ResultEnvelope.init)
            <^> json <| "code"
            <*> json <| "msg"
    }
}

extension ObservableType where Self.Element == ResultEnvelope {

    public func success() -> Observable<Void> {
        return filterMap { env -> FilterMap<Void> in
            return env.code == "0" ? .map(()) : .ignore
        }
    }
}
