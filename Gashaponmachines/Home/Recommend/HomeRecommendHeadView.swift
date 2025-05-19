import UIKit

let HomeRecommendHeadViewId = "HomeRecommendHeadViewId"

class HomeRecommendHeadView: UICollectionReusableView {

    var recommendHeadEnvelope: HomeRecommendHeadEnvelope? {
        didSet {
            self.setupUI()
        }
    }

    private let bannerViewH = Constants.kScreenWidth / 3
    private let activityViewH = 92 + UIFont.heightOfPixel(24)
    private let newViewH = 136 + (Constants.kScreenWidth-56) / 2
    private let hotViewH = HomeRecommendHotCell.cellH * 2 + 116
    private let themeViewH = 347.0
    private let adIvH = Constants.kScreenWidth * 0.25
    /// 内容视图
    private var contentView: UIView?

    private var lastView: UIView!

    func getContentViewHeight(env: HomeRecommendHeadEnvelope) -> CGFloat {
        let margin: CGFloat = 12
        var headViewH: CGFloat = 0
        headViewH += bannerViewH
        headViewH += activityViewH
        for theme in env.machineTopicList {
            if let style = theme.viewStyle {
                switch style {
                case .special:
                    headViewH += (newViewH + margin)
                case .list:
                    headViewH += (hotViewH + margin)
                case .cover:
                    headViewH += (themeViewH + margin)
                case .banner:
                    headViewH += (adIvH + margin)
                }
            }
        }
        // 去除最后一个间距
        headViewH -= margin
        return headViewH
    }
    
    /// 顶部背景图
    let bgIv = UIImageView(image: UIImage(named: "home_top_bg_2"))

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
    }

    var viewMargin: CGFloat = 16

    let screenW = Constants.kScreenWidth

    var adThemes = [HomeTheme]()

    func setupUI() {
        if let env = self.recommendHeadEnvelope {

            if let contentView = self.contentView {
                contentView.removeFromSuperview()
            }

            self.adThemes.removeAll()

            let contentViewH = self.getContentViewHeight(env: env)
            let contentView = UIView.withBackgounrdColor(.clear)
            contentView.frame = CGRect(x: 0, y: 0, width: screenW, height: contentViewH)
            self.addSubview(contentView)
            self.contentView = contentView
            
            if let img = StaticAssetService.shared.envelope?.bannerBackground {
                bgIv.gas_setImageWithURL(img)
            }
            bgIv.frame = CGRect(x: 0, y: 0, width: screenW, height: bannerViewH + activityViewH)
            contentView.addSubview(bgIv)

            let bannerView = HomeRecommendBannerView()
            bannerView.banners = env.bannerList
            bannerView.frame = CGRect(x: 12, y: 0, width: screenW - 24, height: bannerViewH)
            contentView.addSubview(bannerView)

            let activityView = HomeRecommendActivityView(frame: CGRect(x: 12, y: bannerView.bottom, width: screenW - 24, height: activityViewH))
            activityView.icons = env.mainPageIconList
            contentView.addSubview(activityView)

            lastView = activityView

            for theme in env.machineTopicList {
                if lastView.isKind(of: HomeRecommendActivityView.self) {
                    viewMargin = 0
                } else {
                    viewMargin = 12
                }

                if let style = theme.viewStyle {
                    switch style {
                    case .special:
                        createNewView(theme: theme)
                    case .list:
                        createHotView(theme: theme)
                    case .cover:
                        createThemeView(theme: theme)
                    case .banner:
                        createAdView(theme: theme)
                    }
                }
            }
        }
    }

    // 上新
    func createNewView(theme: HomeTheme) {
        let newView = HomeRecommendNewView(frame: CGRect(x: 12, y: lastView.bottom + viewMargin, width: screenW-24, height: newViewH))
        newView.moreButtonClickHandle = {
            RouterService.route(to: theme.topicLink)
        }
        newView.styleInfos = theme.styleInfo
        if let contentView = self.contentView {
            contentView.addSubview(newView)
        }
        lastView = newView
    }

    // 热门
    func createHotView(theme: HomeTheme) {
        let hotView = HomeRecommendHotView()
        hotView.theme = theme
        hotView.frame = CGRect(x: 12, y: lastView.bottom + viewMargin, width: screenW-24, height: hotViewH)
        if let contentView = self.contentView {
            contentView.addSubview(hotView)
        }
        lastView = hotView
    }

    // 专题
    func createThemeView(theme: HomeTheme) {
        let themeView = HomeRecommendThemeView()
        themeView.theme = theme
        themeView.frame = CGRect(x: 12, y: lastView.bottom + viewMargin, width: screenW-24, height: themeViewH)
        if let contentView = self.contentView {
            contentView.addSubview(themeView)
        }
        lastView = themeView
    }

    // 广告
    func createAdView(theme: HomeTheme) {

        self.adThemes.append(theme)

        // 找到该专题的位置
        var index: Int = 0
        for i in 0..<self.adThemes.count {
            let indexTheme = self.adThemes[i]
            if indexTheme.actionTitle == theme.actionTitle {
                index = i
                break
            }
        }

        // 广告背景
        let adIv = UIImageView()
        adIv.layer.cornerRadius = 8
        adIv.layer.masksToBounds = true
        adIv.isUserInteractionEnabled = true
        adIv.gas_setImageWithURL(theme.backgroudImage)
        adIv.frame = CGRect(x: 0, y: lastView.bottom + viewMargin, width: screenW, height: adIvH)
        if let contentView = self.contentView {
            contentView.addSubview(adIv)
        }
        lastView = adIv

        // 查看详情
        let detailView = UIView.withBackgounrdColor(.qu_yellow)
        detailView.layer.cornerRadius = 4
        detailView.layer.masksToBounds = true
        adIv.addSubview(detailView)
        detailView.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.right.equalTo(-12)
            make.width.equalTo(74)
            make.height.equalTo(24)
        }

        let detailTitle = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "查看详情")
        detailView.addSubview(detailTitle)
        detailTitle.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
        }

        let detailIv = UIImageView(image: UIImage(named: "home_more_arrow_theme"))
        detailView.addSubview(detailIv)
        detailIv.snp.makeConstraints { (make) in
            make.left.equalTo(detailTitle.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }

        let detailButton = UIButton()
        detailButton.tag = index
        detailButton.addTarget(self, action: #selector(lookDetail(button:)), for: .touchUpInside)
        adIv.addSubview(detailButton)
        detailButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @objc func lookDetail(button: UIButton) {
        if button.tag < adThemes.count {
            RouterService.route(to: adThemes[button.tag].topicLink)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
