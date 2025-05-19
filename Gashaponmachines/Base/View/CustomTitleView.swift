import Foundation

import UIKit

let CustomTitleViewCellId = "CustomTitleViewCellId"

protocol CustomTitleViewDelegate: class {
    func titleView(_ titleView: CustomTitleView, didSelectItemAt indexPath: IndexPath)
}

enum TitleViewStyle {
    case normal // 紧贴, 非固定方式(商城首页)
    case divide // 平分, 固定方式(发货列表)
}

class CustomTitleView: UIView {
    
    public weak var delegate: CustomTitleViewDelegate?
    
    /// 标题数组
    public var titles = [String]() {
        didSet {
            self.titleView.reloadData()
        }
    }
    
    /// 风格
    var style: TitleViewStyle = .normal
    
    /// 当前展示的视图
    var currentIndex: Int = 0 {
        didSet {
            self.titleView.reloadData()
        }
    }
    
    /// 标题视图
    private lazy var titleView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        if style == .divide {
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = .zero
        }else {
            layout.minimumInteritemSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = (style == .normal)
        cv.register(CustomTitleViewCell.self, forCellWithReuseIdentifier: CustomTitleViewCellId)
        return cv
    }()
    
    init(style: TitleViewStyle) {
        super.init(frame: .zero)
        
        self.style = style
        self.backgroundColor = .clear
        
        addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    var isLineHidden: Bool = false
    
    func hiddenBottomLine(_ isHidden: Bool) {
        isLineHidden = isHidden
        self.titleView.reloadData()
    }
    
    public func scrollToItem(indexPath: IndexPath) {
        self.titleView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomTitleView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomTitleViewCellId, for: indexPath) as! CustomTitleViewCell
        if isLineHidden {
            cell.configure(title: self.titles[indexPath.row], isSelect: false)
        }else {
            cell.configure(title: self.titles[indexPath.row], isSelect: currentIndex == indexPath.row)
        }
        return cell
    }
}

extension CustomTitleView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if style == .divide {
            return CGSize(width: Constants.kScreenWidth/CGFloat(titles.count), height: 44)
        }else {
            let w = self.titles[indexPath.row].sizeOfString(usingFont: UIFont.boldSystemFont(ofSize: 16)).width
            return CGSize(width: w, height: 44)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.titleView(self, didSelectItemAt: indexPath)
        self.currentIndex = indexPath.row
        self.titleView.reloadData()
    }
}


class CustomTitleViewCell: UICollectionViewCell {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .qu_black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    lazy var line: UIView = {
        let view = UIView.withBackgounrdColor(.new_yellow)
        view.layer.cornerRadius = 2.5
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        line.isHidden = true
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.bottom.equalTo(-4)
            make.centerX.equalToSuperview()
            make.left.equalTo(label).offset(8)
            make.right.equalTo(label).offset(-8)
            make.height.equalTo(5)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isSelect: Bool) {
        clean()
        
        label.text = title
        label.textColor = isSelect ? .qu_black : .qu_lightGray
        line.isHidden = !isSelect
    }
    
    func clean() {
        label.text = ""
        line.isHidden = true
    }
}
