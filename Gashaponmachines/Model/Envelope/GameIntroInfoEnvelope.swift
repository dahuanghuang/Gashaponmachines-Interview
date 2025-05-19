import Argo
import Curry
import Runes
import RxDataSources

public struct GameIntroInfoEnvelope {
    var images: [String]?
}

extension GameIntroInfoEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GameIntroInfoEnvelope> {
        return curry(GameIntroInfoEnvelope.init)
            <^> json <||? "introImages"
    }
}
