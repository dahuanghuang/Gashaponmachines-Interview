import Lottie

class LottieConfig {

    static let KoiBundle: Bundle = Bundle(path: Bundle.main.path(forResource: "lucky_anim_koi", ofType: "bundle")!)!

    static let CritCritingBundle: Bundle = Bundle(path: Bundle.main.path(forResource: "crit_criting", ofType: "bundle")!)!

    static let CritMoreThan1Bundle: Bundle = Bundle(path: Bundle.main.path(forResource: "crit_grow_and_one", ofType: "bundle")!)!

    static let Crit0To1Bundle: Bundle = Bundle(path: Bundle.main.path(forResource: "crit_grow_from_zero_to_one", ofType: "bundle")!)!

    static let CritLessThan1Bundle: Bundle = Bundle(path: Bundle.main.path(forResource: "crit_grow_not_fill", ofType: "bundle")!)!

    static let CritTransitionBundle: Bundle = Bundle(path: Bundle.main.path(forResource: "crit_transition", ofType: "bundle")!)!
    
    /// 登录背景
    static let LoginBackgroundBundle: Bundle = Bundle(path: Bundle.main.path(forResource: "login_bg", ofType: "bundle")!)!
    /// 兑换蛋壳成功
    static let ExchangeSuccessBundle: Bundle = Bundle(path: Bundle.main.path(forResource: "exchange_success", ofType: "bundle")!)!
    
    
    /// 游戏结果背景动画
//    static let GameResultBgBundle: Bundle = Bundle(path: Bundle.main.path(forResource: "game_result", ofType: "bundle")!)!
}
