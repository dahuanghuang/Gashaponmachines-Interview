// 没用
import RxCocoa
import RxSwift

extension Reactive where Base: AccquiredItemEmptyStateView {
    var playButtonTap: ControlEvent<Void> {
        return self.base.button.rx.controlEvent(.touchUpInside)
    }
}

class AccquiredItemEmptyStateView: UIView {

    let button = UIButton.whiteTextCyanGreenBackgroundButton(title: "去扭蛋")

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.UIColorFromRGB(0xfff7d0)
        let contentView = UIView.withBackgounrdColor(.white)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(4)
        }

        let container = UIView()
        container.isUserInteractionEnabled = false
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalTo(self)
        }

        let iv = UIImageView(image: UIImage(named: "emptyState_dancao"))
        container.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.centerX.equalTo(container)
        }

        let titleLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 28, defaultText: "你还没有开始扭蛋~")
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(container)
            make.top.equalTo(iv.snp.bottom).offset(20)
        }

        container.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.bottom.equalTo(container)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.width.equalTo(120)
            make.height.equalTo(36)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.roundCorners(.allCorners, radius: 4)
    }
}
