import UIKit

/// 网络重连动画视图
class YFSLiveNetConnectAnimationView: UIView {

    func show() {
        self.isHidden = false
    }

    @objc func hide() {
        self.isHidden = true
    }

//    @objc func remove() {
//        self.removeFromSuperview()
//    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    func setupUI() {

        self.isHidden = true

        self.backgroundColor = UIColor.black.alpha(0.6)

        // 移除手势
        let ges = UITapGestureRecognizer(target: self, action: #selector(hide))
        ges.delegate = self
        self.addGestureRecognizer(ges)

        // 白色视图
        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(150)
            make.center.equalToSuperview()
        }

        // 动画视图
        let view1 = UIView()
        view1.backgroundColor = UIColor.white
        contentView.addSubview(view1)
        view1.snp.makeConstraints { (make) in
            make.size.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalTo(30)
        }

        let circleLayer = CAGradientLayer()
        circleLayer.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        circleLayer.cornerRadius = 35
        let color1 = UIColor(hex: "ffd712")!.cgColor
        let color2 = UIColor(hex: "ffb412")!.cgColor
        circleLayer.colors = [color1, color2]
        circleLayer.startPoint = CGPoint(x: 0, y: 0)
        circleLayer.endPoint = CGPoint(x: 1.0, y: 0)
        view1.layer.addSublayer(circleLayer)

        let view2 = UIView()
        view2.layer.cornerRadius = 28
        view2.backgroundColor = UIColor.white
        view1.addSubview(view2)
        view2.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(56)
        }

        let path = UIBezierPath.init(roundedRect: CGRect(x: 7, y: 7, width: 56, height: 56), cornerRadius: 28)
        let maskLayer = CAShapeLayer()
        maskLayer.lineWidth = 20
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.path = path.cgPath
        view1.layer.addSublayer(maskLayer)

        let anima = CABasicAnimation(keyPath: "strokeStart")
        anima.fromValue = NSNumber(value: 0)
        anima.toValue = NSNumber(value: 1.0)
        anima.duration = 1.0
        anima.repeatCount = MAXFLOAT
        maskLayer.add(anima, forKey: "stroke")

        // 提示
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.qu_black
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.text = "连接中..."
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YFSLiveNetConnectAnimationView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchview = touch.view {
            for subview in self.subviews {
                if touchview.isDescendant(of: subview) {
                    return false
                }
            }
        }
        return true
    }
}
