//// 将视频播放器放进来这个类
// class GameNewVideoPlayerHeaderView: UIView {
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    lazy var leftButton        = GameNewExchangeButton()
//    lazy var rightButton       = GameNewRechargeButton()
//    lazy var stateView         = GameNewStatusView()
//    lazy var gamePlayingButton = GameNewPlayingButton()
//    lazy var realTimeInfoView  = GameNewRealtimeInfoView()
//    lazy var countdownView     = GameCountdownView()
//    lazy var gameIdleButton    = GameNewIdleButton()
//    lazy var exitButton        = GameNewExitButton()
//    lazy var reportButton      = GameNewReportButton()
//    
//    lazy var playerView: UIView = {
//        let playerView = UIView()
//        playerView.backgroundColor = .white
//        playerView.layer.cornerRadius = 8
//        playerView.layer.masksToBounds = true
//        return playerView
//    }()
//    
//    lazy var loadingLogoView: UIImageView = {
//        let bgView = UIImageView()
//        bgView.image = UIImage(named: "game_loading_\(self.type)")
//        return bgView
//    }()
//    
//    lazy var rechargePopView: GameRechargePopView = {
//        let view = GameRechargePopView()
//        view.isHidden = true
//        view.button.rx.tap
//            .asDriver()
//            .drive(onNext: { [weak self] in
//                view.isHidden = true
//                let vc = RechargeViewController(isOpenFromGameView: true)
//                vc.delegate = self
//                self?.navigationController?.pushViewController(vc, animated: true)
//            })
//            .disposed(by: view.disposeBag)
//        return view
//    }()
//    
//    lazy var popView: GamePopOverView = {
//        let view = GamePopOverView(delegate: self)
//        view.isHidden = true
//        return view
//    }()
//    
//    private var player: GameMoviePlayerController?
//    
//    func setupHeaderView() -> UIView {
//        //        let height = (Constants.kScreenWidth - 16) * 4 / 3 + 8 + 0.24 * Constants.kScreenWidth + 16
//        let newHeight = 12 + (Constants.kScreenWidth - 16) * 4 / 3 + 8 + 0.384 * Constants.kScreenWidth + 8
//        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: newHeight))
//        containerView.backgroundColor = UIColor.UIColorFromRGB(0xffae12)
//        containerView.layer.cornerRadius = 8
//        containerView.layer.masksToBounds = true
//        
//        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: newHeight - 8))
//        bgView.backgroundColor = .white
//        bgView.layer.cornerRadius = 8
//        bgView.layer.masksToBounds = true
//        containerView.addSubview(bgView)
//        
//        bgView.addSubview(playerView)
//        playerView.snp.makeConstraints { make in
//            make.left.equalTo(bgView).offset(8)
//            make.right.equalTo(bgView).offset(-8)
//            make.top.equalTo(bgView).offset(12)
//            make.height.equalTo(GameConstants.GameVideoPlayerHeight)
//        }
//        
//        playerView.addSubview(loadingLogoView)
//        loadingLogoView.snp.makeConstraints { make in
//            make.edges.equalTo(playerView)
//        }
//        
//        playerView.addSubview(countdownView)
//        countdownView.isHidden = true
//        countdownView.snp.makeConstraints { make in
//            make.edges.equalTo(playerView)
//        }
//        
//        playerView.addSubview(stateView)
//        stateView.snp.makeConstraints { make in
//            make.top.equalTo(playerView).offset(4)
//            make.left.equalTo(playerView).offset(4)
//            make.height.equalTo(36)
//            make.width.greaterThanOrEqualTo(85)
//            make.width.lessThanOrEqualTo(112)
//        }
//        
//        playerView.addSubview(exitButton)
//        exitButton.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(64)
//            make.height.equalTo(48)
//            make.width.equalTo(28+24)
//            make.left.equalToSuperview().offset(-5)
//        }
//        
//        playerView.addSubview(reportButton)
//        reportButton.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(64)
//            make.height.equalTo(48)
//            make.width.equalTo(28+24)
//            make.right.equalToSuperview().offset(5)
//        }
//        
//        exitButton.addTarget(self, action: #selector(leave), for: .touchUpInside)
//        reportButton.addTarget(self, action: #selector(switchToFAQ), for: .touchUpInside)
//        
//        playerView.addSubview(realTimeInfoView)
//        realTimeInfoView.snp.makeConstraints { make in
//            make.right.equalTo(playerView)
//            make.centerY.equalTo(stateView)
//            make.width.equalTo(156)
//            make.height.equalTo(32)
//        }
//        
//        if let player = self.player {
//            player.shutdown()
//            self.player = nil
//        }
//        
//        self.player = setupPlayer(liveAddress: self.liveAddress ?? "")
//        self.player?.prepareToPlay()
//        if let player = self.player {
//            playerView.insertSubview(player.view, belowSubview: countdownView)
//            player.view.snp.makeConstraints { make in
//                make.edges.equalTo(playerView)
//            }
//        }
//        
//        let bgleft = UIImageView.with(imageName: "game_n_bg_1")
//        bgView.addSubview(bgleft)
//        bgleft.snp.makeConstraints { make in
//            make.top.equalTo(playerView.snp.bottom).offset(8)
//            make.left.equalToSuperview()
//            make.width.equalTo(20)
//            make.height.equalTo(124)
//        }
//        
//        bgView.addSubview(leftButton)
//        leftButton.snp.makeConstraints { make in
//            make.left.equalTo(bgleft.snp.right).offset(45/2)
//            make.top.bottom.equalTo(bgleft)
//            make.width.equalTo(GameNewExchangeButton.width)
//            make.height.equalTo(124)
//        }
//        
//        let bgMid = UIImageView.with(imageName: "game_n_bg_2")
//        bgView.addSubview(bgMid)
//        bgMid.snp.makeConstraints { make in
//            make.top.equalTo(playerView.snp.bottom).offset(8)
//            make.left.equalTo(leftButton.snp.right).offset(45/2)
//            make.width.equalTo(8)
//            make.height.equalTo(124)
//        }
//        
//        bgView.addSubview(rightButton)
//        rightButton.snp.makeConstraints { make in
//            make.height.equalTo(96/2)
//            make.right.equalToSuperview().offset(-12)
//            make.bottom.equalTo(bgleft)
//            make.width.equalTo(GameNewIdleButton.width)
//        }
//        
//        containerView.addSubview(gameIdleButton)
//        gameIdleButton.addTarget(self, action: #selector(playGame), for: .touchUpInside)
//        gameIdleButton.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-12)
//            make.height.equalTo(64)
//            make.width.equalTo(GameNewIdleButton.width)
//            make.bottom.equalTo(rightButton.snp.top).offset(-0.032*Constants.kScreenWidth)
//        }
//        
//        bgView.addSubview(gamePlayingButton)
//        gamePlayingButton.addTarget(self, action: #selector(startNow), for: .touchUpInside)
//        gamePlayingButton.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().offset(-3)
//            make.centerX.equalTo(containerView).multipliedBy(0.5)
//            make.size.equalTo(0.416 * Constants.kScreenWidth)
//        }
//        
//        self.playerView.addSubview(popView)
//        popView.snp.makeConstraints { make in
//            make.edges.equalTo(playerView)
//        }
//        
//        self.playerView.addSubview(rechargePopView)
//        rechargePopView.snp.makeConstraints { make in
//            make.edges.equalTo(playerView)
//        }
//        
//        return containerView
//    }
// }
