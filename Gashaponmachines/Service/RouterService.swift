import ESTabBarController_swift
import SwiftNotificationCenter

/// 路由跳转
/// 这个类的主要用途是定义用于 Web 页面跳转的协议
/// https://quqqi.coding.net/p/SS_Gacha/wiki/10
struct RouterService {

    static func route(to urlStr: String?) {
        guard let url = urlStr else {
            HUD.showError(second: 2, text: "urlStr 为空", completion: nil)
            return
        }

        if let url = URL(string: url) {
            route(to: url)
        } else {
            HUD.showError(second: 2, text: "无效的 URL", completion: nil)
        }
    }

//    "yqnd://yqnd.quqqi.com/MallCategory/5a9f601f6d52424a4a0b1ada?a=123&b=345"
//    QLog.debug(urlstr.fragment)
//    QLog.debug(urlstr.path)    => /MallCategory/5a9f601f6d52424a4a0b1ada
//    QLog.debug(urlstr.scheme)  => yqnd
//    QLog.debug(urlstr.query)   => a=123&b=345
//    QLog.debug(urlstr.pathComponents) => ["/", "MallCategory", "5a9f601f6d52424a4a0b1ada"]
    static func route(to url: URL) {
        // 跳转网页
        if url.absoluteString.hasPrefix("http") {
            Broadcaster.notify(Routable.self) {
                $0.notifyForWebview(url: url)
            }
            return
        }

        let pathComponents = url.pathComponents

        if pathComponents.count > 1 {
            let className = pathComponents[1]
            // 非法路径
            guard let path = RoutePath(rawValue: className) else {
                HUD.showError(second: 2, text: "\(className) does not match RouterPath enum", completion: nil)
                return
            }
            // 登录跳转
            let needLogin = RoutePath.needLogin.contains(path)
            if needLogin && AppEnvironment.current.apiService.accessToken == nil {
                Broadcaster.notify(Routable.self) {
                    $0.notifyForLogin()
                }
                return
            }

            var identifier: String = ""
            if pathComponents.count > 2 {
                identifier = pathComponents[2]
            }

            switch className {
            case RoutePath.Game.rawValue:
                if let queryDic = url.queryDictionary, let type = queryDic["type"] {
                    let machineType = MachineColorType(rawValue: type) ?? .white
                    Broadcaster.notify(Routable.self) {
                        $0.notifyForGame(physicId: identifier, type: machineType)
                    }
                } else {
                    QLog.error("需要带 type 字段才能跳转 GameViewController")
                }
            case RoutePath.Main.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForMain()
                }
            case RoutePath.Recharge.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForRecharge()
                }
            case RoutePath.MallProduct.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForMallProduct(mallProductId: identifier)
                }
            case RoutePath.MallCategory.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForMallCategory(mallCategoryId: identifier)
                }
            case RoutePath.EggExchange.rawValue:
                if let queryDic = url.queryDictionary, let type = queryDic["type"], let intType = Int(type) {
                    let eggProductType = EggProductType(rawValue: intType) ?? .general
                    Broadcaster.notify(Routable.self) {
                        $0.notifyForExchange(type: eggProductType)
                    }
                } else {
                    QLog.error("需要带 type 字段才能跳转 ExchangeViewController")
                }
            case RoutePath.Login.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForLogin()
                }
            case RoutePath.Collection.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForCollection(collectionId: identifier)
                }
            case RoutePath.DistinctExchangeRecord.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForDistinctExchangeRecord()
                }
            case RoutePath.EggProduct.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForEggProduct()
                }
            case RoutePath.ShipList.rawValue:
                Broadcaster.notify(Routable.self) {
                    let status = DeliveryStatus(rawValue: Int(identifier) ?? DeliveryStatus.toBeDelivered.rawValue) ?? DeliveryStatus.toBeDelivered
                    $0.notifyForShipList(status: status)
                }
            case RoutePath.RechargeRecord.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForRechargeRecord()
                }
            case RoutePath.EggPointRecord.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForEggPointRecord()
                }
            case RoutePath.Compose.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForCompose()
                }
            case RoutePath.ComposePath.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForComposePath(composePathId: identifier)
                }
            // MARK: - 一番赏
            case RoutePath.OnePieceList.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForOnePieceList()
                }
            case RoutePath.OnePieceMyList.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForOnePieceMyList()
                }
            case RoutePath.OnePiecePlayHistory.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForOnePiecePlayHistory()
                }
            case RoutePath.OnePieceGameDetail.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForOnePieceGameDetail(id: identifier)
                }
            case RoutePath.OnePieceLiveDetail.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForOnePieceLiveDetail(id: identifier)
                }
            case RoutePath.OnePieceEggProduct.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForOnePieceEggProduct()
                }
            case RoutePath.OnePiece.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForOnePiece()
                }
            case RoutePath.Mall.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForMall()
                }
            case RoutePath.MachineTopic.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForMachineTopic(themeId: identifier)
                }
            // MARK: - 我的
            case RoutePath.Conversation.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForConversation()
                }
            case RoutePath.Invitation.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForInvitation()
                }
            case RoutePath.Promocode.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForPromocode()
                }
            case RoutePath.Coupons.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForCoupons()
                }
            case RoutePath.AddressConfig.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForAddressConfig()
                }
            case RoutePath.LogReport.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForLogReport()
                }
            case RoutePath.ChangeEnv.rawValue:
                Broadcaster.notify(Routable.self) {
                    $0.notifyForChangeEnv()
                }

            default:
                break
            }
        }
    }
}
