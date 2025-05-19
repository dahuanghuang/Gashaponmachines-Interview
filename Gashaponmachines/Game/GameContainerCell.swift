import UIKit

protocol GameContainerCellDelegate: class {
    func containerCellScrollViewDidScroll(scrollView: UIScrollView)
    func containerCellScrollViewDidEndDecelerating(scrollView: UIScrollView)
    func didSelectedGameProductTableviewCell(product: Product)
}

class GameContainerCell: BaseTableViewCell {

//    static let ScrollViewContentWidth = Constants.kScreenWidth - ScrollViewPadding * 2
//
//    static let ScrollViewPadding: CGFloat = 8
    
    static let CellHeight = Constants.kScreenHeight - Constants.kStatusBarHeight - 44 - Constants.kScreenBottomInset

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        roundCorners([.bottomLeft, .bottomRight], radius: 4)
    }

    var isSelectedIndex: Bool = false

    lazy var tv: GameLuckyRecordTableViewController = GameLuckyRecordTableViewController()

    lazy var cv: GameProductTableViewController = GameProductTableViewController()

    lazy var dv: GameComboViewController = GameComboViewController()

    var objectCanScroll: Bool = false {
        didSet {
            self.tv.canScroll = objectCanScroll
			self.cv.canScroll = objectCanScroll
            self.dv.canScroll = objectCanScroll
        }
    }

    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Self.CellHeight))
        sv.delegate = self
        sv.backgroundColor = .clear
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.contentSize = CGSize(width: Constants.kScreenWidth * 3, height: Self.CellHeight)
        return sv
    }()

    weak var delegate: GameContainerCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(scrollView)
        configureScrollView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(roomId: String) {
        tv.viewModel.configureWith(roomId: roomId)
        dv.viewModel.configureWith(roomId: roomId)
        cv.viewModel.configureWith(roomId: roomId)
    }

    private func configureScrollView() {
        scrollView.addSubview(cv.view)
        scrollView.addSubview(dv.view)
        scrollView.addSubview(tv.view)
        cv.view.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Self.CellHeight)
        dv.view.frame = CGRect(x: Constants.kScreenWidth, y: 0, width: Constants.kScreenWidth, height: Self.CellHeight)
        tv.view.frame = CGRect(x: Constants.kScreenWidth * 2, y: 0, width: Constants.kScreenWidth, height: Self.CellHeight)
    }
}

extension GameContainerCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isSelectedIndex, scrollView == self.scrollView, let delegate = self.delegate {
            delegate.containerCellScrollViewDidScroll(scrollView: scrollView)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isSelectedIndex = false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView, let delegate = self.delegate {
            delegate.containerCellScrollViewDidEndDecelerating(scrollView: scrollView)
        }
    }
}
