import Argo
import Curry
import Runes
import MessageKit
import Kingfisher

public struct ChatMessageEnvelope {
    var messages: [ChatMessage]
}

extension ChatMessageEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ChatMessageEnvelope> {
        return curry(ChatMessageEnvelope.init)
            <^> json <|| "msgList"
    }
}

public struct ChatMessage {
    // 对话消息类型，[ 1, 2, 3 ] 其中一种，分别表示：1 => text, 2 => image, 3 => video
    let type: ChatMessageType
    // 对话消息内容，文本或资源链接（type == 2 或 type == 3）
    let content: String
    // 对话方向，[ 'SEND', 'RECV' ] 其中一种，SEND 表示用户发送， RECV 表示客服发送
    let direction: String
    // 用户 userId。当 direction 为 RECV 时，此字段为空
    var userId: String
    var avatar: String
    var sendTime: String
    var nickname: String
    var height: Int
    var width: Int
}

public enum ChatMessageType: String {
    case text = "TEXT"
    case image = "IMAGE"
    case video = "VIDEO"
}

extension ChatMessage: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ChatMessage> {
        let a = curry(ChatMessage.init)
        let a1 = a
            <^> (json <| "type").map(String.toChatMessageType)
            <*> (json <| "content" <|> pure(""))
            <*> (json <| "direction" <|> pure(""))

        let a2 = a1 <*> (json <| "userId" <|> pure(""))
            <*> (json <| "avatar" <|> pure(""))
            <*> (json <| "sendTime" <|> pure(""))

        let a3 = a2 <*> (json <| "nickname" <|> pure(""))
            <*> ((json <| ["metaImage", "height"]).map(String.toInt) <|> pure(0))
            <*> ((json <| ["metaImage", "width"]).map(String.toInt) <|> pure(0))

        return a3
    }
}

extension String {
    static func toChatMessageType(_ type: String) -> ChatMessageType {
        return ChatMessageType(rawValue: type) ?? .text
    }
}

// MessageKit
extension ChatMessage: Equatable {

}

extension ChatMessage: MediaItem {

    public var url: URL? {
        return URL(string: content)
    }

    public var image: UIImage? {
        guard let imgURL = url else { return nil }
//        return KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: imgURL.absoluteString)
        return nil
    }

    public var placeholderImage: UIImage {
        return UIImage(named: "index_placeholder")!
    }

    public var size: CGSize {
        var w: Int = width
        var h: Int = height
        if CGFloat(w/h) <= 0.345 {
            w = 56
            h = w * height / width
        } else if  CGFloat(w/h) > 0.345 && CGFloat(w/h) <= 3.25 {
            w = 130
            h = w * height / width
        } else {
            h = 40
            w = h * width / height
        }
        return CGSize(width: w, height: h)
    }
}

extension ChatMessage: MessageType {
    public var sender: SenderType {
        return Sender(id: userId, displayName: userId)
    }

    public var messageId: String {
        return ""
    }

    public var sentDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(Int(sendTime) ?? 0) / 1000)
    }

    public var kind: MessageKind {
        if type == .image {
            return MessageKind.photo(self)
        } else if type == .text {
            return MessageKind.text(content)
        } else {
            return MessageKind.text(content)
        }
    }
}
