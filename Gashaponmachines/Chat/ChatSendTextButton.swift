// import MessageInputBar
import InputBarAccessoryView

class ChatSendTextButton: InputBarButtonItem {

    override init(frame: CGRect) {
        super.init(frame: frame)

        setTitle("发送", for: .normal)
        setTitleColor(.qu_black, for: .normal)
        titleLabel?.font = UIFont.withPixel(28)
        backgroundColor = .qu_yellow
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
