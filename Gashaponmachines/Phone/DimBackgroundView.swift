open class DimBackgroundView: UIView {

    /// if true, dissmissGesture will be invalid
    open var canDismissOnBackgroundTap: Bool = false

    private static var autoFrame: CGRect {
        if let currentWindow = UIApplication.shared.keyWindow {
            return currentWindow.frame
        } else {
            return CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kScreenHeight)
        }
    }

    var tapGes: UITapGestureRecognizer?

    override init(frame: CGRect) {
        super.init(frame: DimBackgroundView.autoFrame)

        self.backgroundColor = UIColor.black.alpha(0.6)
        let ges = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(ges)
        ges.delegate = self
        self.tapGes = ges
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func dismiss() {
        self.removeFromSuperview()
    }
}

extension DimBackgroundView: UIGestureRecognizerDelegate {

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.tapGes && canDismissOnBackgroundTap {
            return true
        }
        return false
    }
}
