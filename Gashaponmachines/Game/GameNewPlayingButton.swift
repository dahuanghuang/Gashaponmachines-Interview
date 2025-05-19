import Lottie
import SnapKit

extension GameNewPlayingButton: GameComponentAction {

    func on(state: Game.State) {
        switch state {
        case .ready:
            isEnabled = true
            isHidden = false
            transformView.isHidden = false
            transformView.image = UIImage(named: "game_n_playing_btn_enable")
            transform()
        case .go:
            isHidden = false
            rotate()
        case .act:
            delay(0.8) {
                self.isEnabled = false
                self.transformView.image = UIImage(named: "game_n_playing_btn_disable")
            }
        case .win:
            isEnabled = false
            transformView.layer.removeAllAnimations()
        case .err, .reset:
            isHidden = true
        default:
            return
        }
    }
}

// 正在扭蛋的旋转按钮
class GameNewPlayingButton: UIControl {

    // 是否正在旋转
    var isRotating: Bool = false

    let transformView = UIImageView(image: UIImage(named: "game_n_playing_btn_enable"))

    override init(frame: CGRect) {

        super.init(frame: frame)
        isHidden = true
        
        let bgIv = UIImageView(image: UIImage(named: "game_n_playing_btn_bg"))
        addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(self.transformView)
        transformView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    // 开始旋转
    private func rotate() {
        dispatch_sync_safely_main_queue {
            CATransaction.begin()
            isRotating = true
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.repeatCount = 0
            animation.duration = 6.8
            animation.fromValue = 0
            animation.toValue = Float.pi * 2
            CATransaction.setCompletionBlock {
                self.isRotating = false
            }
            transformView.layer.add(animation, forKey: "rotation")
            CATransaction.commit()
        }
    }

    // 开始变化
    private func transform() {
        dispatch_sync_safely_main_queue {
            self.transform = CGAffineTransform(scaleX: 0.04, y: 0.04)
            UIView.animateKeyframes(withDuration: 0.93, delay: 0.0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.17, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.47, relativeDuration: 0.23, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.23, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }, completion: nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
