// class CompositionDetailMaterialLockButton: UIButton {
//
//    var status: ComposeMaterial.LockStatus = .forbid {
//        didSet {
//            self.isEnabled = status.isEnabled
//            self.setTitle(status.title, for: .normal)
//            self.layer.borderColor = status.color.cgColor
//            self.setTitleColor(status.color, for: .normal)
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.titleLabel?.font = UIFont.withPixel(20)
//        self.layer.cornerRadius = 10
//        self.layer.borderWidth = 1
//        self.isEnabled = status.isEnabled
//        self.setTitle(status.title, for: .normal)
//        self.layer.borderColor = status.color.cgColor
//        self.setTitleColor(status.color, for: .normal)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
// }

// protocol CompositionDetailMaterialCollectionCellDelegate: class {
//    func lockButtonTapped(orderId: String)
// }

class CompositionDetailMaterialCollectionCell: UICollectionViewCell {

//    weak var delegate: CompositionDetailMaterialCollectionCellDelegate?

    fileprivate lazy var dashedBorderImageView = DashedLineBorderImageView()

//    lazy var lockButton = CompositionDetailMaterialLockButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

//        self.contentView.addSubview(lockButton)
//        lockButton.addTarget(self, action: #selector(lock), for: .touchUpInside)
//        lockButton.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-12)
//            make.size.equalTo(CGSize(width: 40, height: 20))
//        }

        self.contentView.addSubview(dashedBorderImageView)
        dashedBorderImageView.snp.makeConstraints { make in
//            make.size.equalTo(64)
//            make.top.equalTo(self.contentView).offset(12)
//            make.centerX.equalTo(self.contentView)
//            make.bottom.equalTo(lockButton.snp.top).offset(-8)
            make.edges.equalToSuperview()
        }
    }

    private var orderId: String = ""

//    @objc func lock() {
//        self.delegate?.lockButtonTapped(orderId: self.orderId)
//    }

    func configureWith(material: ComposeMaterial) {
        self.orderId = material.orderId
//        lockButton.status = material.lockStatus
        dashedBorderImageView.configureWith(material: material)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dashedBorderImageView.reset()
//        lockButton.status = .forbid
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class DashedLineBorderImageView: UIView {

    lazy var icon = UIImageView()

//    lazy var lockView = UIImageView.with(imageName: "compo_detail_white_lock")

//    lazy var maskV = UIView.withBackgounrdColor(UIColor.UIColorFromRGB(0xc0f0fe, alpha: 0.6))

    lazy var imageView = UIImageView()

    // 虚线
    lazy var dashedLineBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
//        layer.strokeColor = UIColor.compos_borderColor.cgColor
        layer.strokeColor = UIColor(hex: "fff5de")?.cgColor
        layer.fillColor = nil
        layer.lineDashPattern = [4, 2]
        return layer
    }()

//    lazy var strokeLayer: CAShapeLayer = {
//       	let layer = CAShapeLayer()
//        layer.strokeColor = UIColor.compos_borderColor.cgColor
//        layer.lineWidth = 4
//        layer.fillColor = nil
//        return layer
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview()
            make.size.equalTo(13)
        }

//        addSubview(maskV)
//        maskV.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        addSubview(lockView)
//        lockView.snp.makeConstraints { make in
//            make.size.equalTo(16)
//            make.center.equalToSuperview()
//        }
//        self.lockView.isHidden = true
//        self.maskV.isHidden = true

        layer.insertSublayer(dashedLineBorderLayer, below: icon.layer)
    }

    func configureWith(material: ComposeMaterial) {
        dashedLineBorderLayer.removeFromSuperlayer()
//        layer.insertSublayer(strokeLayer, below: icon.layer)
        imageView.gas_setImageWithURL(material.image)
        icon.gas_setImageWithURL(material.icon)
//        lockView.isHidden = material.lockStatus != .locked
//        maskV.isHidden = material.lockStatus != .locked
    }

    func reset() {
//        strokeLayer.removeFromSuperlayer()
        layer.insertSublayer(dashedLineBorderLayer, below: icon.layer)
        imageView.image = nil
        icon.image = nil
//        lockView.isHidden = true
//        maskV.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashedLineBorderLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 4).cgPath
        dashedLineBorderLayer.frame = self.bounds

//        strokeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 4).cgPath
//        strokeLayer.frame = self.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
