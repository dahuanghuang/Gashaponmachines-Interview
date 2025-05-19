import MJRefresh

// protocol ScrollViewConvertible {}
//
// extension UITableView: ScrollViewConvertible {}
// extension UICollectionView: ScrollViewConvertible {}

protocol Refreshable {
//    var refreshHeader: MJRefreshHeader? { get set }
//    var refreshFooter: MJRefreshFooter? { get set }
}

enum RefreshComponentType {
    case index
    case mall
    case chat
}

extension Refreshable where Self: UIViewController {

    func initRefreshHeader(_ type: RefreshComponentType, scrollView: UIScrollView, _ action: @escaping () -> Void) -> MJRefreshHeader {

        var header: MJRefreshHeader?
        if type == .index {
            header = RefreshIndexHeader(refreshingBlock: { action() })
        } else if type == .mall {
            header = RefreshMallHeader(refreshingBlock: { action() })
        } else if type == .chat {
            header = RefreshChatHeader(refreshingBlock: { action() })
        }
        scrollView.mj_header = header
        return scrollView.mj_header
    }

    func initRefreshFooter(_ type: RefreshComponentType, scrollView: UIScrollView, _ action: @escaping () -> Void) -> MJRefreshFooter {
        var footer: MJRefreshFooter?
        if type == .index {
            footer = RefreshIndexFooter(refreshingBlock: { action() })
        } else if type == .mall {
            footer = RefreshMallFooter(refreshingBlock: { action() })
        }

        scrollView.mj_footer = footer
        return scrollView.mj_footer
    }

    func initBlackRefreshFooter(scrollView: UIScrollView, _ action: @escaping () -> Void) -> MJRefreshFooter {
        let footer = RefreshBlackFooter(refreshingBlock: { action() })
        scrollView.mj_footer = footer
        return scrollView.mj_footer
    }
}

class RefreshMallHeader: MJRefreshNormalHeader {

    override func placeSubviews() {
        super.placeSubviews()
        self.stateLabel.textColor = .white
        self.lastUpdatedTimeLabel.isHidden = true
        self.arrowView.tintColor = .white
    }
}

class RefreshMallFooter: MJRefreshAutoGifFooter {

    lazy var iv: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "refresh_footer_bottom_white"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override func placeSubviews() {
        super.placeSubviews()

        self.stateLabel.isHidden = true
        self.setTitle("", for: .noMoreData)
        self.isRefreshingTitleHidden = true

        self.addSubview(iv)
        iv.frame = self.bounds
    }
}

class RefreshIndexHeader: MJRefreshNormalHeader {

    override func placeSubviews() {
    	super.placeSubviews()
        self.lastUpdatedTimeLabel.isHidden = true
    }
}

class RefreshIndexFooter: MJRefreshAutoGifFooter {

    lazy var iv: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "refresh_footer_bottom_white"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override func placeSubviews() {
        super.placeSubviews()

        self.stateLabel.isHidden = true
        self.setTitle("", for: .noMoreData)
        self.isRefreshingTitleHidden = true

        self.addSubview(iv)
        iv.frame = self.bounds
    }
}

class RefreshChatHeader: MJRefreshNormalHeader {

    override func placeSubviews() {
        super.placeSubviews()
        self.lastUpdatedTimeLabel.isHidden = true
        self.stateLabel.isHidden = true
    }
}

class RefreshBlackFooter: MJRefreshAutoGifFooter {

    lazy var iv: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "refresh_footer_bottom"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override func placeSubviews() {
        super.placeSubviews()

        self.stateLabel.isHidden = true
        self.setTitle("", for: .noMoreData)
        self.isRefreshingTitleHidden = true

        self.addSubview(iv)
        iv.frame = self.bounds
    }
}
