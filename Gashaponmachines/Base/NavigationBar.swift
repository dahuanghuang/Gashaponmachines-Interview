//import UIKit
//
//enum NavigationBarStyle: String {
//    case index // 首页
//    case mall // 蛋壳商城
//}
//
//class NavigationBar: UINavigationBar {
//
//    init(style: NavigationBarStyle) {
//        super.init(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 44))
//
//        let bg = UIImageView(image: UIImage(named: "\(style.rawValue)_nav_bg"))
//        addSubview(bg)
//        bg.snp.makeConstraints { make in
//            make.left.right.bottom.equalTo(self)
//            make.height.equalTo(25)
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override var intrinsicContentSize: CGSize {
//        return UIView.layoutFittingExpandedSize
//    }
//}
