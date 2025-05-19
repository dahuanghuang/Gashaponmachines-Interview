import ESTabBarController_swift

//class ExampleBasicContentView: ESTabBarItemContentView {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        textColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
//        highlightTextColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
//        iconColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
//        highlightIconColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//class ExampleBackgroundContentView: ExampleBasicContentView {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        textColor = .qu_darkGray
//        highlightTextColor = .qu_black
//        iconColor = UIColor.init(white: 165.0 / 255.0, alpha: 1.0)
//        highlightIconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
//        backdropColor = UIColor.init(red: 37/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1.0)
//        highlightBackdropColor = UIColor.init(red: 22/255.0, green: 24/255.0, blue: 25/255.0, alpha: 1.0)
//    }
//
//    public convenience init(specialWithAutoImplies implies: Bool) {
//        self.init(frame: CGRect.zero)
//        textColor = .qu_darkGray
//        highlightTextColor = .qu_black
//        iconColor = .white
//        highlightIconColor = .white
//        backdropColor = UIColor.init(red: 17/255.0, green: 86/255.0, blue: 136/255.0, alpha: 1.0)
//        highlightBackdropColor = UIColor.init(red: 22/255.0, green: 24/255.0, blue: 25/255.0, alpha: 1.0)
//        if implies {
//            let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ExampleBackgroundContentView.playImpliesAnimation(_:)), userInfo: nil, repeats: true)
//            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
//        }
//
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc internal func playImpliesAnimation(_ sender: AnyObject?) {
//        if self.selected == true || self.highlighted == true {
//            return
//        }
//        let view = self.imageView
//        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
//        impliesAnimation.values = [1.15, 0.8, 1.15]
//        impliesAnimation.duration = 0.3
//        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
//        impliesAnimation.isRemovedOnCompletion = true
//        view.layer.add(impliesAnimation, forKey: nil)
//    }
//}
//
//class ExampleBounceAnimationContentView: ExampleBackgroundContentView {
//
//    public var duration = 0.3
//
//    override func selectAnimation(animated: Bool, completion: (() -> Void)?) {
//        self.bounceAnimation()
//        completion?()
//    }
//
//    override func reselectAnimation(animated: Bool, completion: (() -> Void)?) {
//        self.bounceAnimation()
//        completion?()
//    }
//
//    func bounceAnimation() {
//        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
//        impliesAnimation.values = [1.1, 0.9, 1.0]
//        impliesAnimation.duration = duration
//        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
//        imageView.layer.add(impliesAnimation, forKey: nil)
//    }
//}

class CustomTabBarItemContentView: ESTabBarItemContentView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backdropColor = .white.alpha(0.9)
        self.highlightBackdropColor = .white.alpha(0.9)
        self.renderingMode = .alwaysOriginal
    }
    
    public var duration = 0.3

    override func selectAnimation(animated: Bool, completion: (() -> Void)?) {
        self.bounceAnimation()
        completion?()
    }

    override func reselectAnimation(animated: Bool, completion: (() -> Void)?) {
        self.bounceAnimation()
        completion?()
    }

    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.1, 0.9, 1.0]
        impliesAnimation.duration = duration
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
