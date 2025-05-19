import Argo
import Curry
import Runes

public struct ShipAddressListEnvelope {
    var addressList: [DeliveryAddress]
}

extension ShipAddressListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ShipAddressListEnvelope> {
        return curry(ShipAddressListEnvelope.init)
            <^> json <|| "addressList"
    }
}
