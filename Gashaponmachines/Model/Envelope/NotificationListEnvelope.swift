import Argo
import Runes
import Curry

public struct NotificationListEnvelope {
    var notifications: [Notice]
}

extension NotificationListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<NotificationListEnvelope> {
        return curry(NotificationListEnvelope.init)
            <^> json <|| "notifications"
    }
}
