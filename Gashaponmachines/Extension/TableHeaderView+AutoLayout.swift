//https://gist.github.com/marcoarment/1105553afba6b4900c10#gistcomment-1933639
import UIKit

extension UITableView {

    func layoutTableHeaderView() {

        guard let headerView = self.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let headerWidth = headerView.bounds.size.width
        let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[headerView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)), metrics: ["width": headerWidth], views: ["headerView": headerView])

        headerView.addConstraints(temporaryWidthConstraints)

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame

        frame.size.height = height
        headerView.frame = frame

        self.tableHeaderView = headerView

        headerView.removeConstraints(temporaryWidthConstraints)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }

    func layoutTableFooterView() {

        guard let footerView = self.tableFooterView else { return }
        footerView.translatesAutoresizingMaskIntoConstraints = false

        let footerWidth = footerView.bounds.size.width
        let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[footView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)), metrics: ["width": footerWidth], views: ["footView": footerView])

        footerView.addConstraints(temporaryWidthConstraints)

        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()

        let headerSize = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = footerView.frame

        frame.size.height = height
        footerView.frame = frame

        self.tableFooterView = footerView

        footerView.removeConstraints(temporaryWidthConstraints)
        footerView.translatesAutoresizingMaskIntoConstraints = true
    }

}

extension UITableView {

    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableFooterView = header
        // Tip:这里要先计算子视图的高度后，再去更新tableHeaderView的布局
        for view in header.subviews {
            guard let label = view as? UILabel, label.numberOfLines == 0 else { continue }
            // 设置子视图的preferredMaxLayoutWidth
            label.preferredMaxLayoutWidth = label.frame.width
        }
        // 更新tableHeaderView的布局
        header.setNeedsLayout()
        header.layoutIfNeeded()
        var frame = header.frame

        //        let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        //        //let height = header.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize).height
        //        frame.size.height = height

        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        frame.size = size

        header.frame = frame
        self.tableFooterView = header
    }

}
