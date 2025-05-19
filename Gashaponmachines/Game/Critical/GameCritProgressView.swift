import UIKit

open class GameCritProgressView: UIProgressView {
    // MARK: - Public properties
    public var gradientColorList: [UIColor] = [UIColor.white] {
        didSet {
            gradientLayer.colors = gradientColorList.cgColors
        }
    }

    open override var progress: Float {
        didSet {
            setNeedsLayout()
        }
    }

    // MARK: - Private properties
    private var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.anchorPoint = .zero
        layer.startPoint = .zero
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        return layer
    }()

    // MARK: - Constructor
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProgressView()
    }

    // MARK: - Public methods

    open override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.width*CGFloat(self.progress), height: self.height)
    }

    // MARK: - Private methods
    private func setupProgressView() {
        backgroundColor = .white

        trackTintColor = .clear
        progressTintColor = .clear

        gradientLayer.colors = gradientColorList.cgColors

        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension Array where Element: UIColor {
    var cgColors: [CGColor] {
        return map { $0.cgColor }
    }
}
