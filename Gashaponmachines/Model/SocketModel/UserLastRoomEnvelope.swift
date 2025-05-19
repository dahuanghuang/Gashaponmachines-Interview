import Argo
import Curry
import Runes

public struct UserLastRoomEnvelope {
    var type: MachineColorType
    var physicId: String
}

extension UserLastRoomEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserLastRoomEnvelope> {
        return curry(UserLastRoomEnvelope.init)
            <^> json <| ["data", "type"]
            <*> json <| ["data", "physicId"]
    }
}
