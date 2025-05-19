import Argo
import Curry
import Runes

public struct MachineListEnvelope {
    var machines: [GasMachine]
}

extension MachineListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<MachineListEnvelope> {
        return curry(MachineListEnvelope.init)
            <^> json <|| "machines"
    }
}
