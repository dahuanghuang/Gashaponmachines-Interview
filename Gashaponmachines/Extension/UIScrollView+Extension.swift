import RxCocoa
import RxSwift
import UIKit

extension UIScrollView {

    /**
     Scrolls to the top. If the scroll view happens to be a table view, we try scrolling to the (0, 0)
     index path, and otherwise we just set the content offset directly.
     */
    public func scrollToTop() {
        if let tableView = self as? UITableView,
            tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {

            tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)

        } else {
            self.setContentOffset(CGPoint(x: 0.0, y: -self.contentInset.top), animated: true)
        }
    }
}

extension Reactive where Base: UIScrollView {
    var reachedBottom: Observable<Void> {
        return base.rx.contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let base = base else {
                    return Observable.empty()
                }
                return base.contentOffset.y + base.frame.size.height + 20 > base.contentSize.height ? Observable.just(()) : Observable.empty()
        }
    }
}

/// Trigger: 是否滚到底
extension Reactive where Base: UIScrollView {
    var shouldBatchFetching: ControlEvent<Void> {
        let shouldFetching = didScroll.flatMap { [weak base] _ -> Observable<Void> in

            guard let scrollView = base else {
                return Observable.empty()
            }

            let currentOffSetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
            let remainScreen = (contentHeight - currentOffSetY) / visibleHeight

            return remainScreen <= 2.5 ? Observable.just(()) : Observable.empty()
        }

        return ControlEvent(events: shouldFetching)
    }
}
