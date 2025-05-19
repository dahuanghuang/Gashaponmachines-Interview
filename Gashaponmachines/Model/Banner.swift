import Argo
import Runes
import Curry

public struct Banner {
    let picture: String
    let action: String
}

extension Banner: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Banner> {
        return curry(Banner.init)
            <^> json <| "picture"
            <*> json <| "action"
    }
}
