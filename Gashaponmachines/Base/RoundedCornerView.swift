class RoundedCornerView: UIView {

    // MARK: Properties

    /// The color of the border line.
    @IBInspectable var borderColor: UIColor = .white

    /// The width of the border.
    @IBInspectable var borderWidth: CGFloat = 1 / UIScreen.main.scale

    /// The drawn corner radius.
    @IBInspectable var cornerRadius: CGFloat = 4

    /// The color that the rectangle will be filled with.
    @IBInspectable var fillColor: UIColor = UIColor.white

    // MARK: UIView Methods

    var corners: UIRectCorner
    var radius: CGFloat

    init(corners: UIRectCorner, radius: CGFloat, backgroundColor: UIColor = .white) {
        self.corners = corners
        self.radius = radius
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        roundCorners(self.corners, radius: self.radius)
//        addShadow(offset: CGSize(width: 0, height: -10), color: .black, radius: 5, opacity: 1.0)
    }
}
