import RxCocoa
import RxSwift

private let CompositionDetailTableHeaderViewBackgroundHeight = 32 + 200 + 32 + UIFont.heightOfBoldPixel(36) + 16 + 16 + 36 + 40 + 36 + 20

class CompositionDetailTableHeaderView: UIView {

    static let height = CompositionDetailTableHeaderViewBackgroundHeight + 16 + UIFont.heightOfPixel(32) + 24 + 44 + 24

    lazy var imageView = UIImageView()

    lazy var labelImageView = UIImageView()

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 36)

    lazy var originPriceLabel = UILabel.with(textColor: UIColor.qu_lightGray, fontSize: 28)

    lazy var compositionPriceLabel = UILabel.with(textColor: UIColor(hex: "ff7645")!, fontSize: 28)

    lazy var progressView = CompositionDetailProgressView()

    lazy var errorLabel: UILabel = {
        let label = UILabel.with(textColor: UIColor.qu_lightGray, fontSize: 20)
        label.textAlignment = .center
        return label
    }()

    var announcementView: CompositionDetailAnnouncementView?

    lazy var composeButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()

    lazy var detailActionControl = UIButton()

    var introImages: [String] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

//        self.backgroundColor = UIColor.white
        self.backgroundColor = UIColor(hex: "ffe6ac")

        let bg = UIImageView()
        bg.image = UIImage(named: "compo_detail_bg")?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImage.ResizingMode.tile)
        self.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(CompositionDetailTableHeaderViewBackgroundHeight)
        }

        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(32)
            make.centerX.equalTo(self)
            make.size.equalTo(200)
        }

        imageView.addSubview(labelImageView)
        labelImageView.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 134/2, height: 20))
        }

        let arrow = UIImageView.with(imageName: "compo_detail_arrow")
        addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.centerY.equalTo(imageView)
            make.left.equalTo(imageView.snp.right).offset(-14)
        }

        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(32)
            make.centerX.equalTo(imageView)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }

        let priceView = UIView()
        addSubview(priceView)
        priceView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalTo(titleLabel)
        }

        priceView.addSubview(compositionPriceLabel)
        compositionPriceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceView)
            make.left.equalTo(priceView).offset(4)

        }

        priceView.addSubview(originPriceLabel)
        originPriceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceView)
            make.right.equalTo(priceView).offset(-4)
            make.left.equalTo(compositionPriceLabel.snp.right).offset(5)
        }

        addSubview(composeButton)
        composeButton.layer.cornerRadius = 20
        composeButton.layer.masksToBounds = true
        composeButton.snp.makeConstraints { make in
            make.centerX.equalTo(priceView)
            make.size.equalTo(CGSize(width: 200, height: 40))
            make.top.equalTo(priceView.snp.bottom).offset(36)
        }

        let shadow = UIImageView.with(imageName: "compo_detail_shadow")
        addSubview(shadow)
        shadow.snp.makeConstraints { make in
            make.centerX.equalTo(composeButton)
            make.left.right.equalTo(self)
            make.top.equalTo(composeButton.snp.bottom).offset(36)
        }

        let desLabel = UILabel.with(textColor: .qu_black, fontSize: 32, defaultText: "- 进度详情 -")
        addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.top.equalTo(shadow.snp.bottom).offset(16)
            make.centerX.equalTo(self)
        }

        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.height.equalTo(44+24)
            make.width.equalTo(Constants.kScreenWidth - 40)
            make.top.equalTo(desLabel.snp.bottom).offset(24)
            make.bottom.equalTo(self)
        }

        bg.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(composeButton.snp.bottom).offset(5)
            make.centerX.equalTo(composeButton)
        }

        addSubview(detailActionControl)
        detailActionControl.snp.makeConstraints { make in
            make.left.equalTo(imageView)
            make.right.equalTo(arrow)
            make.top.bottom.equalTo(imageView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: CompositionDetailTableHeaderView {

    var enabled: Binder<Bool> {
        return Binder(self.base) { (view, enabled) -> Void in
            self.base.composeButton.isEnabled = enabled
        }
    }

    var announcements: Binder<[String]> {
        return Binder(self.base) { (view, strings) -> Void in
            self.base.announcementView?.removeFromSuperview()
            let v = CompositionDetailAnnouncementView(strings: strings)
            self.base.addSubview(v)
        	v.snp.makeConstraints { make in
                make.top.left.equalToSuperview()
                make.height.equalTo(strings.count * 48)
                make.width.equalTo(200)
            }
            self.base.announcementView = v
        }
    }

    var composeAction: ControlEvent<Void> {
        return self.base.composeButton.rx.tap
    }

    var switchToDetailAction: ControlEvent<Void> {
        return self.base.detailActionControl.rx.tap
    }

    var envelope: Binder<ComposePathDetailEnvelope> {
        return Binder(self.base) { (view, envelope) -> Void in
            view.labelImageView.gas_setImageWithURL(envelope.label)
            view.imageView.gas_setImageWithURL(envelope.image)
            view.introImages = envelope.introImages
            view.titleLabel.text = envelope.title
            view.originPriceLabel.addStrikeThroughLine(with: "\(envelope.worth) 蛋壳")
            view.compositionPriceLabel.text = "\(envelope.originalWorth) 蛋壳"
            view.progressView.blueValue = Float(envelope.progress.ownMaterialCount) / Float(envelope.progress.totalMaterialCount)
            view.progressView.progressValue = envelope.progress.percentage
            view.composeButton.setTitle(envelope.composeStatusTip, for: .normal)
            view.errorLabel.text = envelope.composeStatusSubTip

            if envelope.composeStatus == .ok {
                view.composeButton.setBackgroundColor(color: UIColor(hex: "ff7645")!, forUIControlState: .normal)
                view.composeButton.setTitleColor(.white, for: .normal)
//                view.composeButton.setTitle("合成", for: .normal)
            } else if envelope.composeStatus == .soldOut {
                view.composeButton.setBackgroundColor(color: UIColor.qu_lightGray, forUIControlState: .normal)
                view.composeButton.setTitleColor(.white, for: .normal)
//                view.composeButton.setTitle("来晚了，已兑换完了", for: .normal)
            } else if envelope.composeStatus == .notEnough {
                view.composeButton.setBackgroundColor(color: UIColor(hex: "ffb983")!, forUIControlState: .normal)
                view.composeButton.setTitleColor(UIColor(hex: "ffd7bb"), for: .normal)
//                view.composeButton.setTitle("合成", for: .normal)
            } else if envelope.composeStatus == .reachLimit || envelope.composeStatus == .reachDayLimit {
                view.composeButton.setBackgroundColor(color: UIColor.qu_lightGray, forUIControlState: .normal)
                view.composeButton.setTitleColor(.white, for: .normal)
//                view.composeButton.setTitle("已达合成上限", for: .normal)
            }
        }
    }
}
