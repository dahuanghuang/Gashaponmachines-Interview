import RxCocoa
import RxSwift

class NotificationTableViewCell: BaseTableViewCell {

    private let container = UIView.withBackgounrdColor(.white)

    private let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    private let contentLabel = UILabel.with(textColor: .new_gray, fontSize: 24)

    private let dateLabel = UILabel.with(textColor: .new_lightGray, fontSize: 20)

    private let iv = UIView.withBackgounrdColor(.UIColorFromRGB(0xFF602E))

    private let indicator = UIImageView.with(imageName: "select_indicator")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.backgroundColor = .new_backgroundColor
        
        self.contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(12)
            make.right.equalTo(self.contentView).offset(-12)
            make.bottom.equalTo(self.contentView).offset(-12)
        }

        iv.layer.cornerRadius = 5
        container.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(container).offset(16)
            make.left.equalTo(container).offset(12)
            make.size.equalTo(10)
        }

        container.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(container).offset(-12)
            make.size.equalTo(16)
        }

        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iv)
            make.left.equalTo(28)
            make.right.equalTo(indicator.snp.left).offset(-8)
        }

        contentLabel.numberOfLines = 0
        contentLabel.preferredMaxLayoutWidth = Constants.kScreenWidth - 76
        container.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalTo(12)
            make.right.equalTo(indicator.snp.left).offset(-12)
        }

        container.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.left.equalTo(contentLabel)
            make.bottom.equalTo(container).offset(-12)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        container.roundCorners(.allCorners, radius: 8)
    }

    func configureWith(notification: Notice) {
        self.titleLabel.text = notification.title
        self.contentLabel.text = notification.content
        self.contentLabel.setLineSpacing(lineHeightMultiple: 1.5)
        self.dateLabel.text = notification.noticeTime
        if let set = AppEnvironment.userDefault.setForKey(key: NotificationViewController.NotificationReadNoticesUserDefaultKey) {
            iv.isHidden = set.contains(notification.notificationId)
        }
        indicator.isHidden = notification.action == nil ? true : false
        titleLabel.snp.updateConstraints { make in
            make.centerY.equalTo(iv)
            make.right.equalTo(indicator.snp.left).offset(-8)
            make.left.equalTo(iv.isHidden ? 12: 28)
        }
    }

    func bind(to state: BehaviorRelay<Set<String>>, as item: String) {
        state.map { $0.contains(item) }
            .bind(to: self.iv.rx.isHidden)
            .disposed(by: rx.reuseBag)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
