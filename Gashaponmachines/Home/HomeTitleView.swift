import UIKit

let HomeViewTitleCellId = "HomeViewTitleCellId"

protocol HomeTitleViewDelegate: class {
    func titleView(_ titleView: HomeTitleView, didSelectItemAt indexPath: IndexPath)
}

class HomeTitleView: UIView {
    
    public weak var delegate: HomeTitleViewDelegate?
    
    /// 标题数组
    public var titles = [String]() {
        didSet {
            self.titleView.reloadData()
        }
    }
    
    /// 当前展示的视图
    var currentIndex: Int = 0 {
        didSet {
            self.titleView.reloadData()
        }
    }
    
    /// 标题视图
    private lazy var titleView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(HomeViewTitleCell.self, forCellWithReuseIdentifier: HomeViewTitleCellId)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func scrollToItem(indexPath: IndexPath) {
        self.titleView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeTitleView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewTitleCellId, for: indexPath) as! HomeViewTitleCell
        cell.configure(title: self.titles[indexPath.row], isSelect: currentIndex == indexPath.row)
        return cell
    }
}

extension HomeTitleView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let w = self.titles[indexPath.row].sizeOfString(usingFont: UIFont.withBoldPixel(28)).width + 24
        return CGSize(width: w, height: 32)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.showChildViewController(at: indexPath.row)
//        self.scrollToPointVc(indexPath: indexPath)
        self.delegate?.titleView(self, didSelectItemAt: indexPath)
        self.currentIndex = indexPath.row
        self.titleView.reloadData()
    }
}
