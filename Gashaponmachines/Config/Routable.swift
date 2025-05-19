protocol Routable: class {

    func notifyForMain()

    func notifyForGame(physicId: String, type: MachineColorType)

    func notifyForRecharge()

    func notifyForMallCategory(mallCategoryId: String)

    func notifyForMallProduct(mallProductId: String)

    func notifyForWebview(url: URL)

    func notifyForExchange(type: EggProductType)

    func notifyForLogin()

    func notifyForCollection(collectionId: String)

    func notifyForDistinctExchangeRecord()

    func notifyForEggProduct()

    func notifyForShipList(status: DeliveryStatus)

    func notifyForRechargeRecord()

    func notifyForEggPointRecord()

    func notifyForCompose()

    func notifyForComposePath(composePathId: String)

    // MARK: - 一番赏
    func notifyForOnePieceList()

    func notifyForOnePieceMyList()
    /// 一番赏购买记录
    func notifyForOnePiecePlayHistory()
    /// 一番赏详情页
    func notifyForOnePieceGameDetail(id: String)
    /// 一番赏直播页
    func notifyForOnePieceLiveDetail(id: String)
    /// 一番赏蛋槽
    func notifyForOnePieceEggProduct()
    /// 一番赏首页
    func notifyForOnePiece()
    /// 商城
    func notifyForMall()
    /// 专题列表
    func notifyForMachineTopic(themeId: String)

    // MARK: - 我的页面
    // 客服
    func notifyForConversation()
    // 邀请好友
    func notifyForInvitation()
    // 兑换码
    func notifyForPromocode()
    // 优惠券
    func notifyForCoupons()
    // 地址管理
    func notifyForAddressConfig()
    // 上传日志
    func notifyForLogReport()
    // 切换环境
    func notifyForChangeEnv()
}

// 提供给web调用的路由协议定义
// https://quqqi.coding.net/p/SS_Gacha/wiki/10
enum RoutePath: String, CaseIterable {
    case Main
    case Game
    case Recharge
    case MallCategory
    case MallProduct
    case Webview
    case EggExchange
    case Login
    case Collection
    case DistinctExchangeRecord

    case EggProduct
    case ShipList
    case RechargeRecord
    case EggPointRecord
    case Compose
    case ComposePath

    case OnePieceList // 在售元气赏列表
    case OnePieceMyList // 我的元气赏列表
    case OnePiecePlayHistory // 元气赏购买记录
    case OnePieceGameDetail // 元气赏游戏详情页
    case OnePieceLiveDetail // 元气赏游戏开奖页
    case OnePieceEggProduct // 蛋槽-元气赏展架

    case OnePiece // 元气赏首页
    case Mall // 商城
    case MachineTopic // 专题列表

    case Conversation // 元气赏首页
    case Invitation // 商城
    case Promocode  // 专题列表
    case Coupons   // 专题列表
    case AddressConfig  // 专题列表
    case LogReport   // 专题列表
    case ChangeEnv  // 专题列表

	// 需要登录的页面：
    // 游戏页面，充值，兑换蛋壳，邀请，蛋壳记录，充值记录，发货列表
    static let needLogin = [Game, Recharge, EggExchange, Invitation, DistinctExchangeRecord, EggPointRecord, RechargeRecord, ShipList, Compose, ComposePath]
}

import ESTabBarController_swift

extension MainViewController: Routable {

    // 商城合集
    func notifyForCollection(collectionId: String) {
        jumpToVc(vc: MallCollectionViewController(mallProductId: collectionId))
    }

    // 用户喜好商城兑换
    func notifyForDistinctExchangeRecord() {
        HUD.showError(second: 2, text: "此协议不再支持", completion: nil)
    }

    func notifyForLogin() {
        guard AppEnvironment.current.apiService.accessToken == nil else { return }
        let vc = LoginViewController.controller
        vc.modalPresentationStyle = .fullScreen
        self.topMostViewController.present(vc, animated: true, completion: nil)
    }

    func notifyForMain() {
        if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {
            if root.presentedViewController != nil {
                root.dismiss(animated: true, completion: nil)
            }

            if let top = self.selectedViewController as? NavigationController {
                top.popToRootViewController(animated: false)
                self.selectedIndex = 0
                return
            }

            if let top = self.selectedViewController?.topMostViewController as? NavigationController {
                top.popToRootViewController(animated: false)
                self.selectedIndex = 0
            }
        }
    }

    func notifyForExchange(type: EggProductType) {
        jumpToVc(vc: ExchangeViewController(type: type))
    }

    func notifyForGame(physicId: String, type: MachineColorType) {
        let vc = NavigationController(rootViewController: GameNewViewController(physicId: physicId, type: type))
        vc.modalPresentationStyle = .fullScreen
        presentToVC(vc: vc)
    }

    func notifyForRecharge() {
        jumpToVc(vc: RechargeViewController(isOpenFromGameView: false))
    }

    func notifyForMallCategory(mallCategoryId: String) {
        jumpToVc(vc: MallCategoryViewController(categoryId: mallCategoryId))
    }

    func notifyForMallProduct(mallProductId: String) {
        jumpToVc(vc: MallDetailViewController(mallProductId: mallProductId))
    }

    func notifyForWebview(url: URL) {
        self.jumpToVc(vc: WKWebViewController(url: url, headers: [:]))
    }

    // 蛋槽
    func notifyForEggProduct() {
        if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
            if AppEnvironment.isYfs {
                root.selectedIndex = 3
            } else {
                root.selectedIndex = 2
            }
        }
    }

    // 发货记录
    func notifyForShipList(status: DeliveryStatus) {
        jumpToVc(vc: DeliveryRecordViewController(status: status))
    }

    // 充值记录
    func notifyForRechargeRecord() {
        jumpToVc(vc: RechargeRecordViewController())
    }

    // 蛋壳明细
    func notifyForEggPointRecord() {
        jumpToVc(vc: MallRecordViewController())
    }

    // 合成主页
    func notifyForCompose() {
        jumpToVc(vc: CompositionViewController())
    }

    // 合成商品详情页
    func notifyForComposePath(composePathId: String) {
        jumpToVc(vc: CompositionDetailViewController(composePathId: composePathId))
    }

    // MARK: - 一番赏
    func notifyForOnePieceList() {
        if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
            if AppEnvironment.isYfs {
                root.selectedIndex = 1
            }
        }
    }

    func notifyForOnePieceMyList() {
        if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
            if AppEnvironment.isYfs {
                root.selectedIndex = 1
            }
        }
    }

    func notifyForOnePiecePlayHistory() {
        jumpToVc(vc: YiFanShangRecordViewController())
    }

    func notifyForOnePieceGameDetail(id: String) {
        jumpToVc(vc: YiFanShangDetailViewController(recordId: id))
    }

    func notifyForOnePieceLiveDetail(id: String) {
        jumpToVc(vc: YFSLivestreamViewController(roomId: id))
    }

    func notifyForOnePieceEggProduct() {
        if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
            if AppEnvironment.isYfs {
                root.selectedIndex = 3
            } else {
                root.selectedIndex = 2
            }
        }
    }

    /// 一番赏首页
    func notifyForOnePiece() {
        if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
            if AppEnvironment.isYfs {
                root.selectedIndex = 1
            }
        }
    }

    /// 商城
    func notifyForMall() {
        if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
            if AppEnvironment.isYfs {
                root.selectedIndex = 2
            } else {
                root.selectedIndex = 1
            }
        }
    }

    /// 专题列表
    func notifyForMachineTopic(themeId: String) {
        jumpToVc(vc: HomeThemeViewController(themeId: themeId))
    }

    // 客服
    func notifyForConversation() {
        jumpToVc(vc: FAQViewController())
    }

    // 邀请好友
    func notifyForInvitation() {
        jumpToVc(vc: InviteViewController())
    }

    // 兑换码
    func notifyForPromocode() {
        jumpToVc(vc: GiftViewController())
    }

    // 优惠券
    func notifyForCoupons() {
        jumpToVc(vc: CouponViewController(couponType: .AVAIL))
    }

    // 地址管理
    func notifyForAddressConfig() {
       jumpToVc(vc: AddressListViewController())
    }

    // 上传日志
    func notifyForLogReport() {
        jumpToVc(vc: EventUploadViewController())
    }

    // 切换环境
    func notifyForChangeEnv() {
        jumpToVc(vc: EnvironmentViewController())
    }

    private func jumpToVc(vc: UIViewController) {
        if let top = self.selectedViewController as? NavigationController {
            top.pushViewController(vc, animated: true)
        } else {
            if let top = self.selectedViewController?.topMostViewController as? NavigationController {
                top.pushViewController(vc, animated: true)
            }
        }
    }

    private func presentToVC(vc: UIViewController) {
        if let top = self.selectedViewController as? NavigationController {
            top.present(vc, animated: true, completion: nil)
        } else {
            if let top = self.selectedViewController?.topMostViewController as? NavigationController {
                top.present(vc, animated: true, completion: nil)
            }
        }
    }
}
