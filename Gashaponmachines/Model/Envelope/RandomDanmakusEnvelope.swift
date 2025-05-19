import Argo
import Runes
import Curry

public struct RandomDanmakusEnvelope {
    var danmakus: [UserDanmakuEnvelope]?
    var frequency: String

}

extension RandomDanmakusEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<RandomDanmakusEnvelope> {
        return curry(RandomDanmakusEnvelope.init)
            <^> json <||? "danmakus"
            <*> json <| "frequency"
    }
}
