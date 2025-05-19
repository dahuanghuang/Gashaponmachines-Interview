import UIKit

// 146
public class YiFanShangDetailMagicView: UIView {
    /// 背景图
    let bgIv = UIImageView(image: UIImage(named: "yfs_detail_magic_bg_unopen"))
    
    // 顶部标题区域
    let topContainer = UIView.withBackgounrdColor(.clear)
    /// 标题Logo
    let topIv = UIImageView(image: UIImage(named: "yfs_detail_magic_logo"))
    /// 状态标题
    let topStatusLb = UILabel.with(textColor: UIColor(hex: "9A4312")!, boldFontSize: 28, defaultText: "元气魔法阵充能中")
    
    /// 规则跳转图
    let ruleIv = UIImageView(image: UIImage(named: "yfs_detail_magic_rule"))
    let ruleButton = UIButton()
    
    /// 信息区域
    lazy var infoView: UIView = {
        let view = UIView.withBackgounrdColor(.white)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 信息顶部区域
    let topInfoView = UIView.withBackgounrdColor(.clear)
    /// 魔法值进度条
    let magicProgressView = MagicProgressView()
    /// 魔法值进度值
    lazy var magicProgressLb: UILabel = {
        let lb = UILabel.numberFont(size: 20)
        lb.textColor = .black
        lb.textAlignment = .right
        return lb
    }()
    /// 魔法阵开启次数
    lazy var magicCountLb: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, fontSize: 28)
        lb.textAlignment = .center
        lb.isHidden = true
        return lb
    }()
    
    /// 分割线
    let line = UIView.withBackgounrdColor(UIColor(hex: "FFE5D6")!)
    
    
    /// 信息下左区域
    let bottomLeftInfoView = UIView.withBackgounrdColor(.clear)
    /// 等级加速值
    lazy var levelValueLabel: UILabel = {
        let lb = UILabel.numberFont(size: 14)
        lb.textColor = UIColor(hex: "FF4B6B")
        return lb
    }()
    let levelDescLabel = UILabel.with(textColor: UIColor(hex: "FF7C74")!, fontSize: 20, defaultText: "等级加速")
    
    /// 信息下中区域
    let bottomMidInfoView = UIView.withBackgounrdColor(.clear)
    /// 黑金加速值
    let vipValueLabel = UILabel.with(textColor: UIColor(hex: "bdbdbd")!, fontSize: 20)
    let vipDescLabel = UILabel.with(textColor: UIColor(hex: "ba926a")!, fontSize: 20, defaultText: "黑金加速")
    
    /// 信息下右区域
    let bottomRightInfoView = UIView.withBackgounrdColor(.clear)
    /// 我的积分值
    lazy var scoreValueLabel: UILabel = {
        let lb = UILabel.numberFont(size: 14)
        lb.textColor = UIColor(hex: "FF4B6B")
        return lb
    }()
    let scoreDescLabel = UILabel.with(textColor: UIColor(hex: "FF7C74")!, fontSize: 20, defaultText: "我的积分")
    
    /// 魔法阵入口按钮
    lazy var magicEnterButton: UIButton = {
        let btn = UIButton.with(imageName: "yfs_detail_magic_action")
        btn.isHidden = true
        return btn
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hex: "FFE5D6")
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        // 背景
        self.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(42)
        }
        
        topContainer.addSubview(topIv)
        topIv.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        topContainer.addSubview(topStatusLb)
        topStatusLb.snp.makeConstraints { make in
            make.left.equalTo(topIv.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        // 魔法阵规则
        topContainer.addSubview(ruleIv)
        ruleIv.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
//        ruleButton.addTarget(self, action: #selector(questionButtonClick), for: .touchUpInside)
        topContainer.addSubview(ruleButton)
        ruleButton.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(topContainer)
            make.width.equalTo(50)
        }
        
        // 魔法阵开启入口按钮
        self.addSubview(magicEnterButton)
        magicEnterButton.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom)
            make.right.equalTo(-12)
            make.bottom.equalTo(-12)
            make.width.equalTo(80)
        }
        
        // 信息区域
        self.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(topContainer.snp.bottom)
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.right.equalTo(-12)
        }
        
        infoView.addSubview(topInfoView)
        topInfoView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(36)
        }
        
        topInfoView.addSubview(magicProgressLb)
        magicProgressLb.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }
        
        topInfoView.addSubview(magicProgressView)
        magicProgressView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
            make.right.equalTo(magicProgressLb.snp.left).offset(-12)
        }
        
        topInfoView.addSubview(magicCountLb)
        magicCountLb.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        topInfoView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        infoView.addSubview(bottomLeftInfoView)
        bottomLeftInfoView.snp.makeConstraints { (make) in
            make.top.equalTo(topInfoView.snp.bottom)
            make.left.bottom.equalToSuperview()
        }

        bottomLeftInfoView.addSubview(levelValueLabel)
        levelValueLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomLeftInfoView.snp.centerY)
        }

        bottomLeftInfoView.addSubview(levelDescLabel)
        levelDescLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomLeftInfoView.snp.centerY)
        }

        infoView.addSubview(bottomMidInfoView)
        bottomMidInfoView.snp.makeConstraints { (make) in
            make.left.equalTo(bottomLeftInfoView.snp.right)
            make.top.width.bottom.equalTo(bottomLeftInfoView)
        }

        bottomMidInfoView.addSubview(vipValueLabel)
        vipValueLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomMidInfoView.snp.centerY)
        }

        bottomMidInfoView.addSubview(vipDescLabel)
        vipDescLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomMidInfoView.snp.centerY)
        }

        infoView.addSubview(bottomRightInfoView)
        bottomRightInfoView.snp.makeConstraints { (make) in
            make.left.equalTo(bottomMidInfoView.snp.right)
            make.top.bottom.width.equalTo(bottomMidInfoView)
            make.right.equalToSuperview()
        }

        bottomRightInfoView.addSubview(scoreValueLabel)
        scoreValueLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomRightInfoView.snp.centerY)
        }

        bottomRightInfoView.addSubview(scoreDescLabel)
        scoreDescLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomRightInfoView.snp.centerY)
        }
    }
    
    func configWith(magicDetail: MagicDetail) {
        
        self.changeMagicState(isOpen: magicDetail.canBuyCount >= 1)
        
        if magicDetail.canBuyCount >= 1 {
            let attrM = NSMutableAttributedString(string: "可开启次数: ")
            attrM.append(NSAttributedString(string: "\(magicDetail.canBuyCount)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
            magicCountLb.attributedText = attrM
        }
        
        magicProgressView.setProgress(progress: CGFloat(magicDetail.nextProgress))
        magicProgressLb.text = "\(Int(magicDetail.nextProgress*100.0))%"
        
        levelValueLabel.text = magicDetail.expLevelMultiplierText
        
        if let htmlAttr = magicDetail.blackGoldMultiplierText.htmlToAttributedString {
            let attrM = NSMutableAttributedString(attributedString: htmlAttr)
            attrM.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], range: NSRange(location: 0, length: attrM.length))
            vipValueLabel.attributedText = attrM
        }
        
        scoreValueLabel.text = magicDetail.myPointText
    }
    
    /// 改变魔法阵状态
    func changeMagicState(isOpen: Bool) {
        if isOpen {
            bgIv.image = UIImage(named: "yfs_detail_magic_bg_open")
            topStatusLb.text = "元气魔法阵可开启"
            magicProgressView.isHidden = true
            magicProgressLb.isHidden = true
            magicCountLb.isHidden = false
            scoreDescLabel.text = "下回进度"
            magicEnterButton.isHidden = false
            infoView.snp.updateConstraints { (make) in
                make.right.equalTo(-100)
            }
        } else {
            bgIv.image = UIImage(named: "yfs_detail_magic_bg_unopen")
            topStatusLb.text = "元气魔法阵充能中"
            magicProgressView.isHidden = false
            magicProgressLb.isHidden = false
            magicCountLb.isHidden = true
            scoreDescLabel.text = "我的积分"
            magicEnterButton.isHidden = true
            infoView.snp.updateConstraints { (make) in
                make.right.equalTo(-12)
            }
        }
    }
    
//    @objc func questionButtonClick() {
//        print("YiFanShangDetailMagicView -------- questionButtonClick")
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
