extension BaseViewController {

    func setupDanmakuView(danmaku: UserDanmakuEnvelope) {

        // 设置在最右边
        let font = UIFont.withPixel(32)
        let width = (danmaku.msg as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width + 102
        let y = CGFloat(120 + danmaku.index! * 40)
        let frame = CGRect(x: Constants.kScreenWidth, y: y, width: width, height: 40)
        let danmakuView = DanmakuView(danmaku: danmaku, frame: frame)
        self.view.addSubview(danmakuView)
        danmakuView.start()

        // 移动展示
        UIView.setAnimationCurve(.linear)
        UIView.animate(withDuration: 6.0, animations: {
            danmakuView.frame.origin.x = -danmakuView.width
        }, completion: { finish in
            danmakuView.removeFromSuperview()
            DanmakuService.shared.rows[danmaku.index!] = 0
        })
    }

    func showAlert(launchscreen: PopMenuAdInfo) {
        let pop = LaunchScreenPopoverViewController(launchScreen: launchscreen)
        pop.modalPresentationStyle = .overFullScreen
        pop.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(pop, animated: true, completion: nil)
    }
}

// MARK: - DanmakuReactable
extension GameProductDetailViewController: DanmakuReactable {
    func attemptToSendDanmaku(danmaku: UserDanmakuEnvelope) {
        setupDanmakuView(danmaku: danmaku)
    }
}

extension GameNewViewController: DanmakuReactable {
    func attemptToSendDanmaku(danmaku: UserDanmakuEnvelope) {
        setupDanmakuView(danmaku: danmaku)
    }
}

// MARK: - PopMenuAdInfoReactable
extension HomeViewController: PopMenuAdInfoReactable {
    func attemptToShowAlert(adInfo: PopMenuAdInfo) {
        showAlert(launchscreen: adInfo)
    }
}

extension YiFanShangViewController: PopMenuAdInfoReactable {
    func attemptToShowAlert(adInfo: PopMenuAdInfo) {
        showAlert(launchscreen: adInfo)
    }
}

extension MallViewController: PopMenuAdInfoReactable {
    func attemptToShowAlert(adInfo: PopMenuAdInfo) {
        showAlert(launchscreen: adInfo)
    }
}

extension AccquiredItemViewController: PopMenuAdInfoReactable {
    func attemptToShowAlert(adInfo: PopMenuAdInfo) {
        showAlert(launchscreen: adInfo)
    }
}

extension ProfileViewController: PopMenuAdInfoReactable {
    func attemptToShowAlert(adInfo: PopMenuAdInfo) {
        showAlert(launchscreen: adInfo)
    }
}

extension GameNewViewController: PopMenuAdInfoReactable {
    func attemptToShowAlert(adInfo: PopMenuAdInfo) {
        showAlert(launchscreen: adInfo)
    }
}

extension RechargeViewController: PopMenuAdInfoReactable {
    func attemptToShowAlert(adInfo: PopMenuAdInfo) {
        showAlert(launchscreen: adInfo)
    }
}
