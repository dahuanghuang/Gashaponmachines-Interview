import UIKit

let HomeRecommendBannerCellId = "HomeRecommendBannerCellId"

class HomeRecommendBannerView: UIView {

    private let sectionCount = 1000

    var banners = [HomeBanner]() {
        didSet {
            self.setupUI()
            self.collectionView.reloadData()
        }
    }

    private lazy var collectionView: UICollectionView = {
        let screenW = Constants.kScreenWidth
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: screenW - 24, height: screenW/3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(HomeRecommendBannerCell.self, forCellWithReuseIdentifier: HomeRecommendBannerCellId)
        return cv
    }()

    var timer: Timer?

    var pageControl: HomeBannerPageControl!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }

    private func setupUI() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        pageControl = HomeBannerPageControl(count: self.banners.count)
        let width = pageControl.pointMargin * CGFloat(banners.count - 1) + pageControl.pointWH * CGFloat(banners.count) + pageControl.leftRightEdge * 2
        self.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(16)
            make.width.equalTo(width)
        }

        self.addTimer()
    }

    private func addTimer() {
        if banners.isEmpty { return }
        let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(nextPage), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }

    private func removeTimer() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    /// 滚动到下一页
    @objc func nextPage() {
        let indexPath = self.resetCurrentIndexPath()

        var nextItem = indexPath.item + 1
        var nextSection = indexPath.section

        if nextItem == self.banners.count {
            nextItem = 0
            nextSection += 1
        }

        collectionView.scrollToItem(at: IndexPath(item: nextItem, section: nextSection), at: .left, animated: true)
    }

    /// 重置到中点section
    private func resetCurrentIndexPath() -> IndexPath {
        guard let currentIndexPath = self.collectionView.indexPathsForVisibleItems.last else {
            return IndexPath(item: 0, section: 0)
        }
        let resetIndexPath = IndexPath(item: currentIndexPath.item, section: sectionCount/2)
        self.collectionView.scrollToItem(at: resetIndexPath, at: .left, animated: false)
        return resetIndexPath
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeRecommendBannerView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecommendBannerCellId, for: indexPath) as! HomeRecommendBannerCell
        cell.configWith(imgUrl: banners[indexPath.row].picture)
        return cell
    }
}

extension HomeRecommendBannerView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let banner = banners[indexPath.row]
        RouterService.route(to: banner.action)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.removeTimer()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.addTimer()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.width) % banners.count
        pageControl.currentIndex = page
    }
}

class HomeRecommendBannerCell: UICollectionViewCell {

    let imageView = UIImageView()

    let label = UILabel.with(textColor: .red, boldFontSize: 30)

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func configWith(imgUrl: String) {
        clean()

        imageView.gas_setImageWithURL(imgUrl)
    }

    func clean() {
        imageView.image = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeBannerPageControl: UIControl {

    // 点间距
    let pointMargin: CGFloat = 9
    // 点直径
    let pointWH: CGFloat = 3
    // 左右间距
    let leftRightEdge: CGFloat = 3

    /// 当前位置
    var currentIndex = 0 {
        willSet {
            if newValue != currentIndex {
                let lastView = views[previousIndex]
                lastView.backgroundColor = UIColor.white.alpha(0.8)
                lastView.transform = CGAffineTransform.identity

                let currentView = views[newValue]
                currentView.backgroundColor = UIColor.white.alpha(1.0)
                currentView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)

                previousIndex = newValue
            }
        }
    }

    /// 上一个位置
    private var previousIndex = 0

    /// 圆点视图数组
    private var views = [UIView]()

    init(count: Int) {
        super.init(frame: .zero)

        self.backgroundColor = .clear

        views.removeAll()

        for index in 0..<count {
            let view = UIView()
            view.backgroundColor = UIColor.white.alpha(0.8)
            view.clipsToBounds = true
            view.layer.cornerRadius = 1.5
            self.addSubview(view)
            views.append(view)

            let x = leftRightEdge + CGFloat(index) * (pointWH + pointMargin)
            view.snp.makeConstraints { (make) in
                make.size.equalTo(pointWH)
                make.centerY.equalToSuperview()
                make.left.equalTo(x)
            }

            if index == 0 {
                view.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                view.backgroundColor = UIColor.white.alpha(1.0)
                previousIndex = index
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
