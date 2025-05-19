import MessageKit

class ChatDateHeaderView: MessageReusableView {

    lazy var dateLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 24)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(UIFont.withPixel(24).lineHeight)
            make.bottom.equalToSuperview().offset(-4)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
