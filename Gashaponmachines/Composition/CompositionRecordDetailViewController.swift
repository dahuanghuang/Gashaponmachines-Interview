final class CompositionRecordDetailViewController: BaseViewController {

    init(record: ComposeRecord) {
        super.init(nibName: nil, bundle: nil)
        setupView(record: record)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func setupView(record: ComposeRecord) {
        self.navigationItem.title = record.title
        self.view.backgroundColor = .viewBackgroundColor

        let sv = UIScrollView()
        sv.bounces = false
        sv.showsVerticalScrollIndicator = false
        sv.layer.cornerRadius = 4
        sv.layer.masksToBounds = true
//        sv.backgroundColor = .qu_cyanBlue
        sv.backgroundColor = UIColor(hex: "ffe6ac")
        self.view.addSubview(sv)
        sv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(Constants.kScreenWidth)
        }

        let icon = UIImageView()
        icon.gas_setImageWithURL(record.image)
        sv.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.size.equalTo(200)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 36, defaultText: record.title)
        sv.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(icon)
            make.top.equalTo(icon.snp.bottom).offset(32)
        }

        let composePrizeLabel = UILabel.with(textColor: UIColor(hex: "ff7645")!, fontSize: 28, defaultText: "合成价：\(record.worth) 蛋壳")
        composePrizeLabel.textAlignment = .center
        sv.addSubview(composePrizeLabel)
        composePrizeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        let originPrizeLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "蛋壳价：\(record.originalWorth) 蛋壳")
        originPrizeLabel.textAlignment = .center
        sv.addSubview(originPrizeLabel)
        originPrizeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(composePrizeLabel.snp.bottom).offset(12)
        }

        let timeLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "获得时间：\(record.confirmTime)")
        sv.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(originPrizeLabel.snp.bottom).offset(16)
        }

        let shadow = UIImageView.with(imageName: "compo_detail_shadow")
        sv.addSubview(shadow)
        shadow.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(20)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        let desLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "- 商品详情 -")
        desLabel.textAlignment = .center
        sv.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.top.equalTo(shadow.snp.bottom).offset(16)
            make.width.centerX.equalToSuperview()
        }

        let imageHeight: CGFloat = (Constants.kScreenWidth - 48) * 0.6
        let cornerViewHeight: CGFloat = 24 + imageHeight * CGFloat(record.introImages.count)

        let cornerView = UIView.withBackgounrdColor(.white)
        cornerView.layer.cornerRadius = 8
        cornerView.layer.masksToBounds = true
        sv.addSubview(cornerView)
        cornerView.snp.makeConstraints { make in
            make.top.equalTo(desLabel.snp.bottom).offset(16)
            make.left.equalTo(self.view).offset(12)
            make.right.equalTo(self.view).offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(cornerViewHeight)
        }

        var lastView: UIView = cornerView

        for (idx, img) in record.introImages.enumerated() {

            let iv = UIImageView()
            if let url = URL(string: img) {
                iv.qu_setImageWithURL(url)
            }

            cornerView.addSubview(iv)
            iv.snp.makeConstraints { make in
                if cornerView == lastView {
                    make.top.equalTo(lastView).offset(12)
                } else {
                    make.top.equalTo(lastView.snp.bottom)
                }

                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview().offset(-12)
                make.height.equalTo(imageHeight)
                if idx == record.introImages.count - 1 {
                    make.bottom.equalToSuperview().offset(-12)
                }
            }

            lastView = iv
        }
    }
}
