import UIKit

class YiFanShangDetailRewardInfoViewController: BaseViewController {
    
    var awardInfos = [AwardInfo]()
    
    var selectIndex = 0
    
    let contentView = UIView.withBackgounrdColor(.clear)
    
    /// 奖品列表
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 102, height: 102)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(YiFanShangDetailRewardInfoCell.self, forCellWithReuseIdentifier: YiFanShangDetailRewardInfoCellId)
        return cv
    }()
    
    /// 奖品详情列表
    lazy var listTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.bounces = false
        tv.register(YiFanShangRuleCell.self, forCellReuseIdentifier: YiFanShangRuleCellReusableIdentifier)
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    init(awardInfos: [AwardInfo], selectIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        
        self.awardInfos = awardInfos
        self.selectIndex = selectIndex
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 黑色透明遮罩
        view.backgroundColor = .qu_popBackgroundColor.alpha(0.6)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        tapGes.delegate = self
        view.addGestureRecognizer(tapGes)
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(Constants.kScreenHeight)
            make.left.right.bottom.equalToSuperview()
        }
        
        // 顶部标题背景
        let topBgIv = UIImageView(image: UIImage(named: "yfs_magic_list_bg"))
        topBgIv.isUserInteractionEnabled = true
        contentView.addSubview(topBgIv)
        topBgIv.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let closeButton = UIButton.with(title: "关闭", titleColor: .new_middleGray, fontSize: 24)
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        topBgIv.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.right.bottom.equalToSuperview()
            make.width.equalTo(50)
        }
        
        let logoIv = UIImageView(image: UIImage(named: "yfs_detail_reward_logo"))
        topBgIv.addSubview(logoIv)
        logoIv.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalTo(closeButton)
            make.size.equalTo(18)
        }
        
        let titleLb = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "奖赏详情")
        titleLb.textAlignment = .left
        topBgIv.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.left.equalTo(logoIv.snp.right).offset(4)
            make.centerY.equalTo(closeButton)
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topBgIv.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(126)
        }
        
        contentView.addSubview(listTableView)
        listTableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        delay(0.1) {
            self.showContentView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.scrollToItem(at: IndexPath(row: selectIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func showContentView() {
        self.contentView.snp.updateConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight + 44)
        }
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissVC() {
        self.contentView.snp.updateConstraints { make in
            make.top.equalTo(Constants.kScreenHeight)
        }
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension YiFanShangDetailRewardInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return awardInfos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YiFanShangDetailRewardInfoCellId, for: indexPath) as! YiFanShangDetailRewardInfoCell
        cell.config(awardInfo: awardInfos[indexPath.row], isSelect: selectIndex == indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectIndex = indexPath.row
        collectionView.reloadData()
        listTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
        listTableView.reloadData()
    }
}

extension YiFanShangDetailRewardInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return awardInfos[selectIndex].productIntroImages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YiFanShangRuleCellReusableIdentifier, for: indexPath) as! YiFanShangRuleCell
        cell.configureWith(imageURL: awardInfos[selectIndex].productIntroImages[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return floor((Constants.kScreenWidth - 40) * 0.6)
    }
}

extension YiFanShangDetailRewardInfoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pointView = gestureRecognizer.location(in: view)
        // contentView以外区域可点击
        if gestureRecognizer.isMember(of: UITapGestureRecognizer.self) && contentView.frame.contains(pointView) {
            return false
        }
        return true
    }
}
