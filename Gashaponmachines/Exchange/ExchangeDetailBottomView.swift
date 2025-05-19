import UIKit
import SnapKit
import RxCocoa
import RxSwift

extension Reactive where Base: ExchangeDetailBottomView {
    var tap: ControlEvent<Void> {
        return self.base.confirmButton.rx.controlEvent(.touchUpInside)
    }
}

class ExchangeDetailBottomView: UIView {
    
    let confirmButton = CustomConfirmButton(title: "确定", fontSize: 32)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .new_backgroundColor
        
        self.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(44)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


