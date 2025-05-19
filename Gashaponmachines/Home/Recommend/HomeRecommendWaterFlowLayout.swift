import UIKit

class HomeRecommendWaterFlowLayout: UICollectionViewFlowLayout {
    // MARK: - Public
    public var headViewH: CGFloat = 0
    /// 行间距
    public var rowMargin: CGFloat = 10
    /// 列间距
    public var columnMargin: CGFloat = 10
    /// 四周边距
    public var sectionEdgeInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 24, right: 12)
    /// 列数
    public var columnsCount: Int = 2
    /// 数据源
    public var datas = [HomeMachine]()

    // MARK: - Private
    /// 每列高度
    private var columnHeights = [CGFloat]()
    /// 所有cell的attr属性
    private var attrs = [UICollectionViewLayoutAttributes]()
    /// 内容整体高度
    private var contentHeight: CGFloat = 0

    /// self.init或collectionView.reloadData时调用, 准备布局
    public override func prepare() {
        super.prepare()
        
        // 清除数据
        attrs.removeAll()
        columnHeights.removeAll()

        // 设置初始高度
        for _ in 0..<self.columnsCount {
            columnHeights.append(sectionEdgeInset.top + headViewH)
        }

        // 设置头部视图位置
        let header = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(index: 0))
        header.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: headViewH)
        attrs.append(header)

        // 设置cell高度
        for i in 0..<self.datas.count {
            let attr = self.calculateAttributes(index: i)
            attrs.append(attr)
        }
    }

    /// 计算cell的Attributes
    func calculateAttributes(index: Int) -> UICollectionViewLayoutAttributes {
        var minColumn = 0
        var minColumnHeight = columnHeights[0]
        for i in 0..<columnsCount {
            if columnHeights[i] < minColumnHeight {
                minColumnHeight = columnHeights[i]
                minColumn = i
            }
        }

        // 计算位置
        let width = (Constants.kScreenWidth - sectionEdgeInset.left - sectionEdgeInset.right - CGFloat(columnsCount - 1) * columnMargin) / CGFloat(columnsCount)
        let height = self.calculateCellHeight(index: index, cellW: width)
        let x = sectionEdgeInset.left + (width + columnMargin) * CGFloat(minColumn)
        var y = minColumnHeight
        if y != sectionEdgeInset.top {
            y += rowMargin
        }

        // 更新最短一列高度
        columnHeights[minColumn] = y + height

        // 设置位置
        let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
        attr.frame = CGRect(x: x, y: y, width: width, height: height)

        // 记录内容高度
        let columnHeight = columnHeights[minColumn]
        if contentHeight < columnHeight {
            contentHeight = columnHeight
        }

        return attr
    }

    /// 计算Cell高度
    func calculateCellHeight(index: Int, cellW: CGFloat) -> CGFloat {

        let cell = HomeRecommendWaterFlowCell.init()
        cell.config(machine: datas[index], index: index)

        cell.contentView.snp.makeConstraints { (make) in
            make.width.equalTo(cellW)
        }

        let size = UIView.layoutFittingExpandedSize
        return cell.contentView.systemLayoutSizeFitting(size).height
    }

    // MARK: - Override
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attrs
    }

    public override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: Constants.kScreenWidth, height: contentHeight + sectionEdgeInset.bottom)
        }
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.attrs[indexPath.item]
    }
}
