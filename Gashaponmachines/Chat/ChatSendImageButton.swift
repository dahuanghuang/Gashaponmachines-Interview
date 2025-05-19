// import MessageInputBar
import InputBarAccessoryView

class ChatSendImageButton: InputBarButtonItem {

    lazy var imgView: UIImageView = UIImageView.with(imageName: "chat_send_img")

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 16))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
