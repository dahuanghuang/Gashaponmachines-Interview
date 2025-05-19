//import UIKit
//
//let HomeThemeHeadViewId = "HomeThemeHeadViewId"
//
//class HomeThemeHeadView: UICollectionReusableView {
//    let topIv = UIImageView()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        self.backgroundColor = UIColor(hex: "f5f4f2")
//
//        let topView = UIView.withBackgounrdColor(.clear)
//        topView.layer.masksToBounds = true
//        self.addSubview(topView)
//        topView.snp.makeConstraints { (make) in
//            make.top.left.right.equalToSuperview()
//            make.height.equalTo(themeHeadViewH * 0.7)
//        }
//
//        topView.addSubview(topIv)
//        topIv.snp.makeConstraints { (make) in
//            make.top.left.right.equalToSuperview()
//            make.height.equalTo(themeHeadViewH)
//        }
//    }
//
//    func config(imageUrl: String) {
//        self.topIv.gas_setImageWithURL(imageUrl)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
