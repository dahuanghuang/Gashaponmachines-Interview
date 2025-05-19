import RxSwift
import RxCocoa

class CompositionCollectionViewHeader: UICollectionReusableView {

    lazy var iv = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        iv.layer.masksToBounds = true
        addSubview(iv)
        iv.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        let view = UIView()
        view.backgroundColor = UIColor(hex: "ffe6ac")
        view.layer.cornerRadius = 12
        iv.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(24)
            make.centerY.equalTo(iv.snp.bottom)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(image: String?) {
        self.iv.gas_setImageWithURL(image)
    }
}
