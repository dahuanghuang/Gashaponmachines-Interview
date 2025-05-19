import Foundation
import UIKit
import SnapKit
import RxSwift
import ESTabBarController_swift
import Kingfisher
import AuthenticationServices
import Lottie

let UserPrivacyKey = "UserPrivacyKey"

class NormalLoginViewController: BaseViewController {
    
    let tipViewHeight = Constants.kScreenHeight * 0.1

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        animationView.play()
    }

    let viewModel = LoginViewModel()

    lazy var closeButton = UIButton.with(imageName: "login_close")

    let tipView = UIImageView(image: UIImage(named: "login_tip"))
    
    /// 登录背景动画视图
    var animationView = AnimationView(name: "login_bg", bundle: LottieConfig.LoginBackgroundBundle)
    
    let buttonView = UIView.withBackgounrdColor(.clear)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_yellow
        
        // 动画视图
        let animationBgView = UIView.withBackgounrdColor(.clear)
        view.addSubview(animationBgView)
        animationBgView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.65)
            make.width.equalTo(animationBgView.snp.height)
        }
        
        animationView.loopMode = .loop
        animationBgView.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        animationView.play()
        
        // 遮住动画视图底部的黑线
        let maskView = UIView.withBackgounrdColor(.new_yellow)
        view.addSubview(maskView)
        maskView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(animationBgView)
            make.height.equalTo(2)
        }
        
        // 登录部分
        let loginBtns = setupLoginButtons()
        let loginCount = loginBtns.count
        
        let buttonViewHeight: CGFloat = loginCount <= 2 ? 132 : (CGFloat(loginCount)*66)
        let contentViewHeight: CGFloat = 102 + buttonViewHeight + Constants.kScreenBottomInset
        let contentView = RoundedCornerView(corners: [.topRight], radius: 20)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(contentViewHeight)
        }
        
        let bgIv1 = UIImageView(image: UIImage(named: "login_bg1"))
        contentView.addSubview(bgIv1)
        bgIv1.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.right.equalToSuperview()
            make.width.equalTo(animationBgView).multipliedBy(0.32)
            make.height.equalTo(animationBgView).multipliedBy(0.25)
        }
        
        let bgIv2 = UIImageView(image: UIImage(named: "login_bg2"))
        view.addSubview(bgIv2)
        bgIv2.snp.makeConstraints { make in
            make.left.equalTo(contentView)
            make.bottom.equalTo(contentView.snp.top)
            make.width.equalTo(animationBgView).multipliedBy(0.32)
            make.height.equalTo(animationBgView).multipliedBy(0.24)
        }
        
        let bgIv3 = UIImageView(image: UIImage(named: "login_bg3"))
        view.addSubview(bgIv3)
        bgIv3.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.bottom.equalTo(contentView.snp.top).offset(50)
            make.width.equalTo(animationBgView).multipliedBy(0.34)
            make.height.equalTo(animationBgView).multipliedBy(0.24)
        }
        
        // 隐私
        let privacyView = LoginPrivacyView(viewType: .loginOrRegister)
        privacyView.lookPrivacyHandle = { [weak self] in
            self?.jumpToUserPrivacyVc()
        }
        view.addSubview(privacyView)
        privacyView.snp.makeConstraints { make in
            make.bottom.equalTo(-Constants.kScreenBottomInset-12)
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.kScreenWidth)
            make.height.equalTo(15)
        }

        /// 登录按钮区域视图
        contentView.addSubview(buttonView)
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.left.right.equalToSuperview()
            make.height.equalTo(buttonViewHeight)
        }
        
        if loginCount == 1 {
            let btn = loginBtns[0]
            btn.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(296)
                make.height.equalTo(66)
            }
        }else if loginCount > 1 {
            for (index, btn) in loginBtns.enumerated() {
                btn.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(index != 0 ? index*66+12 : 0)
                    make.centerX.equalToSuperview()
                    make.width.equalTo(296)
                    make.height.equalTo(index == 0 ? 67 : 54)
                }
            }
        }

        // 关闭按钮
        if let vc = UIApplication.shared.keyWindow?.rootViewController, vc is ESTabBarController {
            self.view.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(Constants.kStatusBarHeight + 12)
                make.left.equalTo(self.view).offset(12)
                make.size.equalTo(25)
            }

            view.addSubview(tipView)
            tipView.snp.makeConstraints { make in
                make.top.equalTo(-tipViewHeight)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.73)
                make.height.equalTo(tipViewHeight)
            }
            
            showTipViewAnimation()
        }
    }
    
    /// 初始化登录按钮
    func setupLoginButtons() -> [UIButton] {
        var loginBtns = [UIButton]()
        if (!Platform.isSimulator && WXApiManager.isWechatInstalled) || Platform.isSimulator {
            WXApiManager.shared.delegate = self
            let wechatButton = UIButton.with(imageName: "login_wechat_button", target: self, selector: #selector(wechatLogin))
            buttonView.addSubview(wechatButton)
            loginBtns.append(wechatButton)
        }
        if AppEnvironment.isAppleLogin {
            let appleButton = UIButton.with(imageName: "login_apple_button", target: self, selector: #selector(appleLogin))
            buttonView.addSubview(appleButton)
            loginBtns.append(appleButton)
        }
        if AppEnvironment.isReal || Platform.isSimulator {
            let mallButton = UIButton.with(imageName: "login_mall_button", target: self, selector: #selector(mallLogin))
            buttonView.addSubview(mallButton)
            loginBtns.append(mallButton)
        }
        return loginBtns
    }

    /// 展示用户隐私弹窗
    func showUserPrivacyPopView() {
        let userPrivacy = UserDefaults.standard.object(forKey: UserPrivacyKey)
        if userPrivacy == nil { // 没有展示过
            UserDefaults.standard.setValue(true, forKey: UserPrivacyKey)
            UserDefaults.standard.synchronize()
            let privacyView = UserPrivacyPopView()
            self.view.addSubview(privacyView)
            privacyView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            privacyView.lookPrivacyHandle = { [weak self] in
                self?.jumpToUserPrivacyVc()
            }
        }
    }

    func jumpToUserPrivacyVc() {
        if let config = AppEnvironment.current.config,
            let url = config.siteURLs["userAgreementURL"] {
            self.navigationController?.pushViewController(WKWebViewController(url: URL(string: url)!, headers: [:]), animated: true)
        }
    }

    /// 显示提示视图
    func showTipViewAnimation() {
        delay(0.5) {
            self.tipView.snp.updateConstraints { make in
                make.top.equalTo(Constants.kStatusBarHeight*0.5)
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }, completion: { finished in
                if finished {
                    self.hideTipViewAnimation()
                }
            })
        }
    }
    
    /// 隐藏提示视图
    func hideTipViewAnimation() {
        delay(3) {
            self.tipView.snp.updateConstraints { make in
                make.top.equalTo(-self.tipViewHeight)
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    /// 微信登录
    @objc func wechatLogin() {
        let isSelect = UserDefaults.standard.bool(forKey: PrivacyPoliciesKey)
        if isSelect {
            WXApiManager.wechatLogin(onViewControlelr: self)
        } else {
            HUD.showError(second: 1.0, text: "请同意协议", completion: nil)
        }
    }
    
    /// 苹果登录
    @objc func appleLogin() {
        if #available(iOS 13.0, *) {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }else {
            HUD.showError(second: 1.5, text: "设备系统版本过低, 请使用微信登录", completion: nil)
        }
    }
    
    /// 邮箱登录
    @objc func mallLogin() {
        self.navigationController?.pushViewController(MallLoginViewController(), animated: true)
    }
    
    override func bindViewModels() {
        super.bindViewModels()
        
        closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        showUserPrivacyPopView()
        
        self.viewModel.wechatLoginEnvelope
            .subscribe(onNext: { [weak self] env in
                if env.code == String(GashaponmachinesError.success.rawValue) {
                    self?.loginSuccess(env: env)
                } else {
                    HUD.showError(second: 2, text: env.msg, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        self.viewModel.appleLoginEnvelope
            .subscribe(onNext: { [weak self] env in
                if env.code == String(GashaponmachinesError.success.rawValue) {
                    self?.loginSuccess(env: env)
                } else {
                    HUD.showError(second: 2, text: env.msg, completion: nil)
                }
            })
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
            	HUD.showErrorEnvelope(env: env)
        	})
        	.disposed(by: disposeBag)
    }

    func loginSuccess(env: LoginEnvelope) {
        HUD.success(second: 0.5, text: "登陆成功") {
            AppEnvironment.login(sessionToken: env.sessionToken, user: env.user)
            UIApplication.shared.keyWindow?.rootViewController = MainViewController()
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension NormalLoginViewController: WXApiManagerDelegate {
    func didReceivePayResponse(resp: PayResp) {}

    func didReceiveAuthResponse(resp: SendAuthResp) {
        if resp.errCode == -99 {
            HUD.showError(second: 2, text: "没有安装微信", completion: nil)
        } else {

            if let code = resp.code {
                self.viewModel.wechatRequest.onNext(code)
            } else {
                HUD.showError(second: 2, text: "取消授权登录", completion: nil)
            }
        }
    }
}

extension NormalLoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    /// 登录失败
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        HUD.showError(second: 2, text: "取消授权登录", completion: nil)
    }
    
    /// 登录成功
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 进行客户端后台登录验证
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            var credentialDict = [String: String]()
            
            // 用户ID(唯一)
            credentialDict["id"] = credential.user
            
            //用户名字(familyName: 姓, givenName: 名)
            if let fName = credential.fullName?.familyName, let gName = credential.fullName?.givenName {
                credentialDict["name"] = fName + gName
            }
            // 认证码
            if let codeData = credential.authorizationCode, let codeString = String(data: codeData, encoding: .utf8) {
                credentialDict["code"] = codeString
            }
            // 验证token
            if let tokenData = credential.identityToken, let tokenString = String(data: tokenData, encoding: .utf8) {
                credentialDict["token"] = tokenString
            }
            
            self.viewModel.appleRequest.onNext(credentialDict)
        }
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window ?? UIWindow(frame: UIScreen.main.bounds)
    }
}
