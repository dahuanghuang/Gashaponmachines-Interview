import RxCocoa
import RxSwift

extension Reactive where Base: YiFanShangDetailHeaderView {
    var envelope: Binder<YiFanShangDetailEnvelope> {
        return Binder(self.base) { (view, env) -> Void in
            if let awardInfos = env.awardInfo, let first = awardInfos.first {
                view.rewardIv.gas_setImageWithURL(first.productImage)
                
                view.setupRewardDetailView(env: env)
                
                if let totalCount = env.totalCount {
                    view.setupRewardInfoView(awardInfos: awardInfos, totalCount: totalCount)
                }
            }
            
            if let currentCount = env.currentCount,
                let totalCount = env.totalCount,
                let progress = env.progress,
                let floatProgress = CGFloat(string: progress) {
                view.detailProgressView.setProgress(progress: floatProgress, progressText: "\(currentCount)/\(totalCount)")
            }
            
            view.ticketView.configWith(env: env)
            
            if let isShowMagic = env.isMagic {
                view.showMagicView(isShowMagic)
                if let mDetail = env.magicDetail {
                    view.magicView.configWith(magicDetail: mDetail)
                }
            }
            
            if let tickets = env.ticketList {
                view.showNodataView(tickets.count == 0)
            }
        }
    }
}

class YiFanShangDetailHeaderView: UIView {
    
    /// 查看产品详情回调
    var awardClickHandle: ((Int) -> Void)?
    
    /// 票券以上的高度
    let headContentViewH: CGFloat = Constants.kStatusBarHeight + 351.0
    /// 劵高度
    let ticketViewH: CGFloat = 132.0
    /// 魔法阵
    let magicViewH: CGFloat = 146.0
    /// 没有数据展示视图
    let nodataViewH: CGFloat = 136.0
    
    // 顶部A赏奖品图片
    lazy var rewardIv: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    /// 购买进度视图
    let detailProgressView = YiFanShangDetailProgressView()
    
    /// 票券视图
    let ticketView = YiFanShangDetailTicketView()
    
    /// 魔法阵视图
    lazy var magicView: YiFanShangDetailMagicView = {
        let view = YiFanShangDetailMagicView()
        view.isHidden = true
        return view
    }()
    
    /// 奖品详情视图
    lazy var rewardDetailView: YiFanShangDetailRewardDetailView = {
        let view = YiFanShangDetailRewardDetailView()
        view.lookDetailHandle = { [weak self] index in
            if let handle = self?.awardClickHandle {
                handle(index)
            }
        }
        return view
    }()
    
    /// 右边奖品类型视图(A:1, B:2, C:4等...)
    var rewardInfoView: YiFanShangDetailRewardInfoView?
    
    /// 购买记录视图
    lazy var buyRecordView: RoundedCornerView = {
        let view = RoundedCornerView(corners: [.topLeft, .topRight], radius: 12, backgroundColor: UIColor(hex: "FFF2F3")!)
        let lb = UILabel.with(textColor: UIColor(hex: "FF4B6B")!, boldFontSize: 28, defaultText: "购买记录")
        view.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()
    
    /// 没有数据展示视图
    lazy var noDataView: UIView = {
        let view = UIView.withBackgounrdColor(.white)
        view.layer.cornerRadius = 12
        
        let maskView = UIView.withBackgounrdColor(.white)
        view.addSubview(maskView)
        maskView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        let iv = UIImageView(image: UIImage(named: "yfs_detail_nodata"))
        view.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(106)
            make.height.equalTo(84)
        }
        
        let lb = UILabel.with(textColor: .new_lightGray, boldFontSize: 24, defaultText: "快一起参与元气赏吧~")
        lb.textAlignment = .center
        view.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(hex: "FF7C74")

        // 背景
        let bgIv = UIImageView(image: UIImage(named: "yfs_detail_bg"))
        self.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(678)
        }

        // A赏奖品整体背景
        let rewardBgView = RoundedCornerView(corners: [.bottomLeft, .bottomRight], radius: 12, backgroundColor: UIColor(hex: "FFD3D4")!)
        self.addSubview(rewardBgView)
        rewardBgView.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight + 60)
            make.centerX.equalToSuperview()
            make.size.equalTo(236)
        }
        
        rewardBgView.addSubview(rewardIv)
        rewardIv.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.bottom.equalTo(-4)
        }

        let firstRewardIv = UIImageView(image: UIImage(named: "yfs_detail_first_reward"))
        self.addSubview(firstRewardIv)
        firstRewardIv.snp.makeConstraints { make in
            make.left.equalTo(rewardBgView).offset(-14)
            make.bottom.equalTo(rewardBgView).offset(-8)
        }

        let rewardButton = UIButton()
        rewardButton.tag = 0
        rewardButton.addTarget(self, action: #selector(lookProductDetail), for: .touchUpInside)
        rewardIv.addSubview(rewardButton)
        rewardButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        // 进度条
        self.addSubview(detailProgressView)
        detailProgressView.snp.makeConstraints { make in
            make.top.equalTo(rewardBgView.snp.bottom).offset(20)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(20)
        }
        
        self.addSubview(ticketView)
        ticketView.snp.makeConstraints { make in
            make.top.equalTo(detailProgressView.snp.bottom).offset(15)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(ticketViewH)
        }
        
        self.addSubview(magicView)
        magicView.snp.makeConstraints { make in
            make.top.equalTo(ticketView.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(0)
        }
        
        self.addSubview(rewardDetailView)
        
        self.addSubview(noDataView)
        noDataView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(0)
            make.bottom.equalToSuperview()
        }
        
        self.addSubview(buyRecordView)
        buyRecordView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(42)
            make.bottom.equalTo(noDataView.snp.top)
//            make.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 查看产品详情
    @objc func lookProductDetail(button: UIButton) {
        if let handle = awardClickHandle {
            handle(button.tag)
        }
    }

    /// 设置奖品详情视图
    func setupRewardDetailView(env: YiFanShangDetailEnvelope) {
        if let awardInfos = env.awardInfo {
            let height = self.getRewardDetailViewHeight(awardInfos: awardInfos)
            rewardDetailView.snp.makeConstraints { make in
                make.top.equalTo(magicView.snp.bottom).offset(12)
                make.left.equalTo(12)
                make.right.equalTo(-12)
                make.height.equalTo(height)
            }
            rewardDetailView.configWith(awardInfos: awardInfos)
        }
        
    }
    
    /// 设置奖品类型视图
    func setupRewardInfoView(awardInfos: [AwardInfo], totalCount: String) {
        if self.rewardInfoView == nil {
            let rewardInfoView = YiFanShangDetailRewardInfoView(awardInfos: awardInfos, totalCount: totalCount)
            self.addSubview(rewardInfoView)
            rewardInfoView.snp.makeConstraints { make in
                make.right.equalTo(-12)
                make.bottom.equalTo(detailProgressView.snp.top).offset(-8)
                make.width.equalTo(78)
                make.height.equalTo(41 + 28 * awardInfos.count)
            }
            self.rewardInfoView = rewardInfoView
        }
    }

    /// 获取headerView高度
    func getHeaderHeight(env: YiFanShangDetailEnvelope) -> CGFloat {

        // 卷以上高度 + 券高度
        var height = headContentViewH + ticketViewH
        
        // 魔法阵高度
        if let magic = env.isMagic, magic {
            height += (12 + magicViewH)
        }
        
        // 奖品详情视图高度
        if let awardInfos = env.awardInfo {
            height += (12 + self.getRewardDetailViewHeight(awardInfos: awardInfos))
        }

        // 12间距 + 购买记录高度
        height += 54
        
        // 无数据视图高度
        if let tickets = env.ticketList {
            if tickets.isEmpty {
                height += nodataViewH
            }
        }else {
            height += nodataViewH
        }

        return height
    }
    
    /// 奖品详情视图高度
    func getRewardDetailViewHeight(awardInfos: [AwardInfo]) -> CGFloat {
        // 减去A赏
        let count = awardInfos.count - 1
        if count <= 0 { return 0 }
        
        let row = (count%3 == 0 ? CGFloat(count/3) : CGFloat(count/3 + 1))
        return YiFanShangDetailRewardDetailView.topRewardBgIvH + 42 + (8 + YiFanShangDetailRewardDetailView.rewardViewH) * row + 12
    }
    
    /// 是否显示魔法阵视图
    func showMagicView(_ isShow: Bool) {
        magicView.isHidden = !isShow
        magicView.snp.updateConstraints { make in
            make.top.equalTo(ticketView.snp.bottom).offset(isShow ? 12 : 0)
            make.height.equalTo(isShow ? magicViewH : 0)
        }
    }
    
    /// 是否展示无数据展示视图
    func showNodataView(_ isShow: Bool) {
        noDataView.isHidden = !isShow
        noDataView.snp.updateConstraints { make in
            make.height.equalTo(isShow ? nodataViewH : 0)
        }
    }
}

public class MagicProgressView: UIView {

    let trackAnimationView = UIView.withBackgounrdColor(.qu_yellow)

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.backgroundColor = UIColor(hex: "ececec")
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true

        let progressIv = UIImageView(image: UIImage(named: "yfs_detail_progress_gray"))
        addSubview(progressIv)
        progressIv.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
        }

        trackAnimationView.layer.cornerRadius = 6
        trackAnimationView.layer.masksToBounds = true
        addSubview(trackAnimationView)
        trackAnimationView.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.left)
            make.centerY.height.width.equalToSuperview()
        }

        let trackIv = UIImageView(image: UIImage(named: "yfs_detail_progress_light"))
        trackAnimationView.addSubview(trackIv)
        trackIv.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
        }
    }

    func setProgress(progress: CGFloat) {
        trackAnimationView.snp.remakeConstraints { (make) in
            make.right.equalTo(self.snp.left).offset(self.width * progress)
            make.centerY.height.width.equalToSuperview()
        }
    }
}

