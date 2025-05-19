import Lottie

class ExchangeSuccessViewController: BaseViewController {
    
    /// 兑换成功动画视图
    var animationView = AnimationView(name: "exchange_success", bundle: LottieConfig.ExchangeSuccessBundle)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.view.backgroundColor = .black.alpha(0.6)
        
        // 动画视图
        let animationBgView = UIView.withBackgounrdColor(.clear)
        view.addSubview(animationBgView)
        animationBgView.snp.makeConstraints { make in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.56)
        }
        
        animationBgView.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        animationView.play { [weak self] finished in
            guard let strongself = self else { return }
            if finished {
                strongself.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension ExchangeSuccessViewController {
    
    // 即将进入后台
    @objc private func willEnterForeground(notification: NSNotification) {
        dispatch_async_safely_main_queue {
            self.animationView.stop()
            self.animationView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
