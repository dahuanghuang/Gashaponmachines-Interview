import RxSwift
import RxCocoa

extension Reactive where Base: MallDetailTitleView {
    var backButtonTap: ControlEvent<Void> {
        return self.base.backButton.rx.controlEvent(.touchUpInside)
    }
}

class MallDetailTitleView: UIView {

    let backButton = UIButton.with(imageName: "nav_back_black")
    let titleLb = UILabel.with(textColor: .black, boldFontSize: 32)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        self.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }
        
        self.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }
    }
    
    func config(title: String) {
        titleLb.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
