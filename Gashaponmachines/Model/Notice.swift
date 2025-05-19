import Argo
import Runes
import Curry

struct Notice {

    var notificationId: String

    var title: String

    var content: String?

    var action: String?

    var noticeTime: String?
}

extension Notice: Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<Notice> {
        let t = curry(Notice.init)
        return t
            <^> json <| "notificationId"
            <*> json <| "title"
            <*> json <|? "content"
        	<*> json <|? "action"
        	<*> json <|? "noticeTime"
    }
}
