//
import UIKit

/// 机台标签头部
let HomeMachineListHeadViewId = "HomeMachineListHeadViewId"
/// 机台标签
let HomeMachineHeadViewCellId = "HomeMachineHeadViewCellId"

class HomeMachineListHeadView: UIView {
    /// 选中位置
    var selectIndex: Int = 0

    var machineTypes: [HomeMachineType]!

    var machineTags: [HomeMachineSubTag]?

    var style: HomeMachineListStyle!

    /// 选中机台类型回调
    var selectTypeHandle: ((Int) -> Void)?

    private lazy var segmentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(HomeMachineHeadViewCell.self, forCellWithReuseIdentifier: HomeMachineHeadViewCellId)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.backgroundColor = UIColor(hex: "f5f4f2")

        self.addSubview(segmentView)
        segmentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    /// 全部机台列表
    func setupDatas(style: HomeMachineListStyle, machineTypes: [HomeMachineType]) {
        self.style = style
        self.machineTypes = machineTypes
        segmentView.reloadData()
    }

    /// 其他机台列表
    func setupDatas(style: HomeMachineListStyle, machineTags: [HomeMachineSubTag]?) {
        self.style = style
        self.machineTags = machineTags
        segmentView.reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeMachineListHeadView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if style == .all {
            return machineTypes.count
        } else {
            return machineTags?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeMachineHeadViewCellId, for: indexPath) as! HomeMachineHeadViewCell
        let isSelect = indexPath.row == selectIndex
        if style == .all {
            cell.configure(machineType: machineTypes[indexPath.row], isSelect: isSelect)
        } else {
            if let tags = machineTags {
                cell.configure(machineTag: tags[indexPath.row], isSelect: isSelect)
            }
        }
        return cell
    }
}

extension HomeMachineListHeadView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0
        if style == .all {
            let name = machineTypes[indexPath.row].name
            width = name.sizeOfString(usingFont: UIFont.withBoldPixel(28)).width + 24
        } else {
            if let tags = machineTags {
                let title = tags[indexPath.row].title
                width = title.sizeOfString(usingFont: UIFont.withBoldPixel(28)).width + 24
            }
        }
        return CGSize(width: width, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let handle = selectTypeHandle {
            handle(indexPath.row)
        }
        self.selectIndex = indexPath.row
        self.segmentView.reloadData()
    }
}

class HomeMachineHeadViewCell: UICollectionViewCell {

    private lazy var label: UILabel = {
        let label = UILabel.with(textColor: .qu_lightGray, fontSize: 28)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .new_backgroundColor

        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true

        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(machineType: HomeMachineType, isSelect: Bool) {
        label.text = machineType.name
        label.textColor = isSelect ? .black : .new_gray
        label.font = isSelect ? UIFont.boldSystemFont(ofSize: 12) : UIFont.systemFont(ofSize: 12)
        self.backgroundColor = isSelect ? UIColor(hex: "FFE682"): .white.alpha(0.4)
        self.layer.borderWidth = isSelect ? 1 : 0
        self.layer.borderColor = isSelect ? UIColor(hex: "FFDA60")!.cgColor : UIColor.clear.cgColor
    }

    func configure(machineTag: HomeMachineSubTag, isSelect: Bool) {
        label.text = machineTag.title
        label.textColor = isSelect ? .black : .new_gray
        label.font = isSelect ? UIFont.boldSystemFont(ofSize: 12) : UIFont.systemFont(ofSize: 12)
        self.backgroundColor = isSelect ? UIColor(hex: "FFE682"): .white.alpha(0.4)
        self.layer.borderWidth = isSelect ? 1 : 0
        self.layer.borderColor = isSelect ? UIColor(hex: "FFDA60")!.cgColor : UIColor.clear.cgColor
    }
}
