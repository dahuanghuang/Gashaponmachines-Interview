import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: GameNavigationBar {

    var exitButtonTap: ControlEvent<Void> {
        return self.base.exitButton.rx.tap
    }

    var questionButtonTap: ControlEvent<Void> {
        return self.base.questionButton.rx.tap
    }
}

class GameNavigationBar: UIView {
    let exitButton = UIButton()

    let questionButton = UIButton()

    init() {
        super.init(frame: .zero)

        self.backgroundColor = .new_yellow

        let exitIv = UIImageView(image: UIImage(named: "game_n_back"))
        self.addSubview(exitIv)
        exitIv.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(-8)
            make.size.equalTo(28)
        }
        
        addSubview(exitButton)
        exitButton.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
            make.right.equalTo(exitIv.snp.right).offset(16)
        }
        
        let questionIv = UIImageView(image: UIImage(named: "game_n_question"))
        self.addSubview(questionIv)
        questionIv.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(exitIv)
            make.size.equalTo(28)
        }
        
        addSubview(questionButton)
        questionButton.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
            make.left.equalTo(questionIv.snp.left).offset(-16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
