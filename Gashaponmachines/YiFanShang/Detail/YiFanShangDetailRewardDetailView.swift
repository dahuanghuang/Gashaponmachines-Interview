import UIKit

class YiFanShangDetailRewardDetailView: UIView {
    
    /// 缩放比例
    static let topRewardScale: CGFloat = topRewardBgIvW/351
    /// 顶部A赏视图宽高
    static let topRewardBgIvW: CGFloat = Constants.kScreenWidth - 24
    static let topRewardBgIvH: CGFloat = 198 * topRewardScale
    
    
    /// 奖品列表视图宽高
    static let rewardViewW: CGFloat = (Constants.kScreenWidth - 64) / 3
    static let rewardViewH: CGFloat = ((Constants.kScreenWidth - 64) / 3) * 1.23
    
    /// 查看产品详情点击回调
    public var lookDetailHandle: ((Int) -> Void)?
    
    private let titleContainer = UIView.withBackgounrdColor(.clear)
    
    let topRewardIv = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.backgroundColor = .clear
        
        let topRewardBgIv = UIImageView(image: UIImage(named: "yfs_detail_topreward_bg"))
        self.addSubview(topRewardBgIv)
        topRewardBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(YiFanShangDetailRewardDetailView.topRewardBgIvH)
        }
        
        topRewardIv.layer.cornerRadius = 6
        topRewardIv.layer.masksToBounds = true
        topRewardBgIv.addSubview(topRewardIv)
        topRewardIv.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.equalTo(-4)
            make.height.equalTo(165 * YiFanShangDetailRewardDetailView.topRewardScale)
        }
        
        let ssrIv = UIImageView(image: UIImage(named: "yfs_detail_topreward_ssr"))
        self.addSubview(ssrIv)
        ssrIv.snp.makeConstraints { make in
            make.top.equalTo(-6)
            make.left.equalTo(-2)
            make.width.equalTo(64)
            make.height.equalTo(33)
        }
        
        let maskIv = UIImageView(image: UIImage(named: "yfs_detail_topreward_mask"))
        self.addSubview(maskIv)
        maskIv.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(topRewardBgIv).offset(6 * YiFanShangDetailRewardDetailView.topRewardScale)
            make.height.equalTo(73 * YiFanShangDetailRewardDetailView.topRewardScale)
        }
        
        let rewardBgView = UIView.withBackgounrdColor(.white)
        rewardBgView.layer.cornerRadius = 12
        rewardBgView.layer.masksToBounds = true
        self.insertSubview(rewardBgView, belowSubview: maskIv)
        rewardBgView.snp.makeConstraints { make in
            make.top.equalTo(topRewardBgIv.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        self.addSubview(titleContainer)
        titleContainer.snp.makeConstraints { make in
            make.top.equalTo(rewardBgView)
            make.left.right.equalToSuperview()
            make.height.equalTo(42)
        }
        
        let topIv = UIImageView(image: UIImage(named: "yfs_detail_reward_top"))
        titleContainer.addSubview(topIv)
        topIv.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
        }
        
        let leftIv = UIImageView(image: UIImage(named: "yfs_detail_reward_left"))
        titleContainer.addSubview(leftIv)
        leftIv.snp.makeConstraints { make in
            make.right.equalTo(topIv.snp.left).offset(-18)
            make.bottom.equalTo(topIv)
        }
        
        let rightIv = UIImageView(image: UIImage(named: "yfs_detail_reward_right"))
        titleContainer.addSubview(rightIv)
        rightIv.snp.makeConstraints { make in
            make.left.equalTo(topIv.snp.right).offset(18)
            make.bottom.equalTo(topIv)
        }
        
        let titleLb = UILabel.with(textColor: .black, boldFontSize: 28, defaultText: "奖赏详情")
        titleContainer.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let button = UIButton()
        button.tag = 0
        button.addTarget(self, action: #selector(lookDetail(button:)), for: .touchUpInside)
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.edges.equalTo(topRewardBgIv)
        }
    }
    
    func configWith(awardInfos: [AwardInfo]) {
        var newAwardInfos = awardInfos
        let firstAwardInfo = newAwardInfos.remove(at: 0)
        
        // 展示A赏
        self.topRewardIv.gas_setImageWithURL(firstAwardInfo.productHorizontalImage)
        
        // 展示奖赏列表(排除A赏)
        for (index, info) in newAwardInfos.enumerated() {
            let row = CGFloat(index / 3)
            let column = CGFloat(index % 3)
            
            let rewardView = UIView.withBackgounrdColor(UIColor(hex: "FFE682")!)
            rewardView.layer.cornerRadius = 8
            self.addSubview(rewardView)
            rewardView.snp.makeConstraints { make in
                make.top.equalTo(titleContainer.snp.bottom).offset(8 + (Self.rewardViewH + 8) * row)
                make.left.equalTo(12 + (Self.rewardViewW + 8) * column)
                make.width.equalTo(Self.rewardViewW)
                make.height.equalTo(Self.rewardViewH)
            }
            
            let rewardIv = UIImageView()
            rewardIv.layer.cornerRadius = 6
            rewardIv.layer.masksToBounds = true
            rewardIv.gas_setImageWithURL(info.productImage)
            rewardView.addSubview(rewardIv)
            rewardIv.snp.makeConstraints { make in
                make.top.left.equalTo(2)
                make.right.equalTo(-2)
                make.height.equalTo(rewardIv.snp.width)
            }
            
            let rewardLabel = UILabel.with(textColor: UIColor(hex: "C24D0B")!, boldFontSize: 20, defaultText: info.productWorth)
            rewardLabel.textAlignment = .center
            rewardView.addSubview(rewardLabel)
            rewardLabel.snp.makeConstraints { make in
                make.top.equalTo(rewardIv.snp.bottom)
                make.left.bottom.right.equalToSuperview()
            }
            
            let cornerView = UIView.withBackgounrdColor(UIColor(hex: "FFE682")!)
            cornerView.layer.cornerRadius = 11
            self.addSubview(cornerView)
            cornerView.snp.makeConstraints { make in
                make.top.left.equalTo(rewardView).offset(-2)
                make.size.equalTo(22)
            }
            
            let eggIv = UIImageView()
            eggIv.gas_setImageWithURL(info.eggIcon)
            eggIv.transform = CGAffineTransformMakeRotation(-Double.pi/8)
            cornerView.addSubview(eggIv)
            eggIv.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(24)
            }
            
            let button = UIButton()
            button.tag = index+1
            button.addTarget(self, action: #selector(lookDetail(button:)), for: .touchUpInside)
            rewardView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    @objc func lookDetail(button: UIButton) {
        if let handle = self.lookDetailHandle {
            handle(button.tag)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
