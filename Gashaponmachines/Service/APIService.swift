import Moya
import Alamofire
import RxSwift
//import Result
import Argo

// 注意 这个 extension 返回的都是 ResultEnvelope
// 返回 ResultEnvelope 的接口：ResultEnvelope 的解析依赖于 rootKey 参数
extension APIService {

    public func logoutRequest() -> Observable<ResultEnvelope> {
        return request(.logoutRequest, rootKey: nil)
    }
    
    public func changeUserNicknameOrAvatar(username: String?, imageKey: String?) -> Observable<ResultEnvelope> {
        return request(.changeUserNicknameOrAvatar(username: username, imageKey: imageKey), rootKey: nil)
    }
    
    public func destroyAccount() -> Observable<ResultEnvelope> {
        return request(.destroyAccount, rootKey: nil)
    }

    public func setShipAddressDefault(addressId: String) -> Observable<ResultEnvelope> {
        return request(.setShipAddressDefault(addressId: addressId), rootKey: nil)
    }

    public func reportCrash(physicId: String, cause: String, detail: String, contact: String?) -> Observable<ResultEnvelope> {
        return request(.reportCrash(physicId: physicId, cause: cause, detail: detail, contact: contact), rootKey: nil)
    }

    public func reportUploadClientLogSuccess(key: String) -> Observable<ResultEnvelope> {
        return request(.reportUploadClientLogSuccess(key: key), rootKey: nil)
    }

    public func lockComposeOrders(composePathId: String, orderIds: [String]) -> Observable<ResultEnvelope> {
        return request(.lockComposeOrders(composePathId: composePathId, orderIds: orderIds), rootKey: nil)
    }

    public func composeProduct(composePathId: String) -> Observable<ResultEnvelope> {
        return request(.composeProduct(composePathId: composePathId), rootKey: nil)
    }

    public func addInvitationCode(invitationCode: String) -> Observable<ResultEnvelope> {
        return request(.addInvitationCode(invitationCode: invitationCode), rootKey: nil)
    }

    public func confirmReceive(shipId: String) -> Observable<ResultEnvelope> {
        return request(.confirmReceive(shipId: shipId), rootKey: nil)
    }

    public func applyPromoCode(code: String) -> Observable<ResultEnvelope> {
        return request(.applyPromoCode(code: code), rootKey: nil)
    }

    public func setVerifyCode(target: String, phone: String) -> Observable<ResultEnvelope> {
        return request(.setVerifyCode(target: target, phone: phone), rootKey: nil)
    }

    public func bindPhone(phone: String, code: String) -> Observable<ResultEnvelope> {
        return request(.bindPhone(phone: phone, code: code), rootKey: nil)
    }

    public func sendConvMsg(type: String, content: String, metaImage: CGSize) -> Observable<ResultEnvelope> {
        return request(.sendConvMsg(type: type, content: content, metaImage: metaImage), rootKey: nil)
    }

    public func verifyInAppPurchase(productId: String, receipt: String) -> Observable<ResultEnvelope> {
        return request(.verifyInAppPurchase(productId: productId, receipt: receipt), rootKey: nil)
    }

    public func buyOnePieceAward(onePieceTaskRecordId: String, count: Int) -> Observable<PurchaseResultEnvelope> {
        return request(.buyOnePieceAward(onePieceTaskRecordId: onePieceTaskRecordId, count: count), rootKey: nil)
    }

    public func buyOnePieceMagicAward(onePieceTaskRecordId: String, numbers: [String]) -> Observable<PurchaseResultEnvelope> {
        return request(.buyOnePieceMagicAward(onePieceTaskRecordId: onePieceTaskRecordId, numbers: numbers), rootKey: nil)
    }

    public func invitationFriendSuccess(platform: String) -> Observable<ResultEnvelope> {
        return request(.invitationFriendSuccess(platform: platform), rootKey: nil)
    }

    public func signIn(couponTemplateId: String?) -> Observable<ResultEnvelope> {
        return request(.signIn(couponTemplateId: couponTemplateId), rootKey: nil)
    }
}

/// 这个 Service 专门用来管理网络请求相关
public struct APIService: ServiceType {

    private let requestRandomKey: String = "APIService.requestRandomKey"

    public var currentRequestKey: String? {
        return AppEnvironment.userDefault.string(forKey: requestRandomKey)
    }

    public var accessToken: String? {
        didSet {
            if let token = accessToken {
                let endpointClosure = { (target: GashaponmachineTarget) -> Endpoint in
                    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
                    switch target {
                    default:
                        return defaultEndpoint.adding(newHTTPHeaderFields: ["sessionToken": token])
                    }
                }
                self.core = MoyaProvider<GashaponmachineTarget>(endpointClosure: endpointClosure)
            } else {
                self.core = MoyaProvider<GashaponmachineTarget>()
            }
        }
    }

    public init(accessToken: String? = nil) {
        defer {
            self.accessToken = accessToken
        }
    }

    public func login(_ accessToken: String) -> APIService {
        return APIService(accessToken: accessToken)
    }

    public func logout() -> APIService {
        return APIService(accessToken: nil)
    }

    public func getBanners() -> Observable<BannersEnvelope> {
        return request(.getBanners)
    }

    public func getConvMsgList(page: Int) -> Observable<ChatMessageEnvelope> {
        return request(.getConvMsgList(page: page))
    }

    public func getUnreadConvMsgCount() -> Observable<Int> {
        return request(.getUnreadConvMsgCount)
    }

    public func getMachineList(tagId: String? = nil, type: Int? = nil, page: Int) -> Observable<MachineListEnvelope> {
        return request(.getMachineList(tagId: tagId, type: type, page: page))
    }

    public func getMyselfInfoV2() -> Observable<UserInfoEnvelope> {
        return request(.getMyselfInfoV2)
    }
    
    public func getPersonalInfo() -> Observable<PersonalInfoEnvelope> {
        return request(.getPersonalInfo)
    }

    public func getMyselfInfo() -> Observable<UserInfo> {
        return request(.getMyselfInfo)
    }

    public func getRechargeList() -> Observable<RechargeEnvelope> {
        return request(.getRechargeList)
    }

    public func getPaymentPlanList() -> Observable<PaymentPlanListEnvelope> {
        return request(.getPaymentPlanList)
    }

    public func getAwardDetail(roomId: String) -> Observable<AwardDetailEnvelope> {
        return request(.getAwardDetail(roomId: roomId))
    }

    public func getLuckyEggRecord(roomId: String) -> Observable<LuckyEggRecordEnvelope> {
        return request(.getLuckyEggRecord(roomId: roomId))
    }

    public func getEggProductList(sourceType: Int?, type: Int?, page: Int) -> Observable<EggProductListEnvelope> {
        return request(.getEggProductList(sourceType: sourceType, type: type, page: page))
    }

    public func getUserEggProducts(sourceType: Int, page: Int) -> Observable<UserEggProductEnvelope> {
        return request(.getUserEggProducts(sourceType: sourceType, page: page))
    }

    public func getShipAddressList(page: Int) -> Observable<ShipAddressListEnvelope> {
        return request(.getShipAddressList(page: page))
    }

    public func getUserExchangeEggProducts(sourceType: Int) -> Observable<EggExchangeListEnvelope> {
        return request(.getUserExchangeEggProducts(sourceType: sourceType))
    }

    public func getEggPointLog(page: Int) -> Observable<EggPointLogEnvelope> {
        return request(.getEggPointLog(page: page))
    }

    public func getBalanceLog(page: Int) -> Observable<BalanceLogEnvelope> {
        return request(.getBalanceLog(page: page))
    }

    public func upsertShipAddress(addressId: String?, name: String?, phone: String?, province: String?, city: String?, district: String?, detail: String?) -> Observable<DeliveryAddress> {
        return request(.upsertShipAddress(addressId: addressId, name: name, phone: phone, province: province, city: city, district: district, detail: detail))
    }

    public func exchangeEggPoints(orderIds: [String]) -> Observable<ExchangeEggPointEnvelope> {
        return request(.exchangeEggPoints(orderIds: orderIds))
    }

    public func getUserGameRecord(userId: String) -> Observable<UserGameRecordEnvelope> {
        return request(.getUserGameRecord(userId: userId))
    }

    public func getShipList(status: Int, page: Int) -> Observable<ShipListEnvelope> {
        return request(.getShipList(status: status, page: page))
    }
    
    public func getShipCountAndWorth() -> Observable<ShipWorthEnvelope> {
        return request(.getShipCountAndWorth)
    }

    public func getShipAdddress(addressId: String) -> Observable<DeliveryAddressDetail> {
        return request(.getShipAddress(addressId: addressId))
    }

    public func getShipDetail(shipId: String) -> Observable<ShipDetailEnvelope> {
        return request(.getShipDetail(shipId: shipId))
    }

    public func getShipInfo(orderIds: [String], keys: [String]) -> Observable<ShipInfoEnvelope> {
        return request(.getShipInfo(orderIds: orderIds, keys: keys))
    }

    public func getMallInfoV2(page: Int) -> Observable<MallInfoV2Envelope> {
        return request(.getMallInfoV2(page: page))
    }

    public func getMallProductExchangeRecords(page: Int) -> Observable<MallProductExchangeRecordsEnvelope> {
        return request(.getMallProductExchangeRecords(page: page))
    }

    public func getMallProductDetail(mallProductId: String) -> Observable<MallProductDetailEnvelope> {
        return request(.getMallProductDetail(mallProductId: mallProductId))
    }

    public func register(loginType: String, certificate: String, password: String, code: String) -> Observable<RegisterEnvelope> {
        return request(.register(loginType: loginType, certificate: certificate, password: password, code: code))
    }

    public func getGameRecords(machineType: Int, page: Int) -> Observable<GameRecordEnvelope> {
        return request(.getGameRecords(machineType: machineType, page: page))
    }

    public func getFaq() -> Observable<FAQEnvelope> {
        return request(.getFAQ)
    }

    public func getSortedMallProductList(categoryId: String, page: Int) -> Observable<MallProductListEnvelope> {
        return request(.getSortedMallProductList(categoryId: categoryId, page: page))
    }

    public func getInvitationInfo() -> Observable<InvitationInfoEnvelope> {
        return request(.getInvitationInfo)
    }

    public func getInviteFriendsList(page: Int) -> Observable<InviteFriendsListEnvelope> {
        return request(.getInviteFriendsList(page: page))
    }

    public func getExchangeInfo(mallProductId: String) -> Observable<ShipInfoEnvelope> {
        return request(.getExchangeInfo(mallProductId: mallProductId))
    }

    public func getOccupyRechargeList(roomId: String) -> Observable<RechargeEnvelope> {
        return request(.getOccupyRechargeList(roomId: roomId))
    }

    public func getMallCollectionProductList(mallCollectionId: String, page: Int) -> Observable<MallCollectionProductListEnvelope> {
        return request(.getMallCollectionProductList(mallCollectionId: mallCollectionId, page: page))
    }

    public func getDistinctExchangeRecords(page: Int) -> Observable<MallDistinctExchangeRecordsEnvelope> {
        return request(.getDistinctExchangeRecords(page: page))
    }

    public func getRandomDanmakus() -> Observable<RandomDanmakusEnvelope> {
        return request(.getRandomDanmakus)
    }

    public func getNotificationList(page: Int) -> Observable<NotificationListEnvelope> {
        return request(.getNotificationList(page: page))
    }

    public func getStaticAssets() -> Observable<StaticAssetsEnvelope> {
        return request(.getStaticAssets)
    }

    public func getClientLogReportKey() -> Observable<UploadEventKeyEnvelope> {
        return request(.getClientLogReportKey)
    }

    public func getComposePathList(page: Int) -> Observable<ComposePathListEnvelope> {
        return request(.getComposePathList(page: page))
    }

    public func getComposePathDetail(composePathId: String) -> Observable<ComposePathDetailEnvelope> {
        return request(.getComposePathDetail(composePathId: composePathId))
    }

    public func getComposeRecordList(page: Int) -> Observable<ComposeRecordListEnvelope> {
        return request(.getComposeRecordList(page: page))
    }
    
    public func loginByOAuth(OAuthType: String, installationId: String, code: String?, identityToken: String?, authorizationCode: String?, fullName: String?, appleUserId: String?) -> Observable<LoginEnvelope> {
        return request(.loginByOAuth(OAuthType: OAuthType, installationId: installationId, code: code, identityToken: identityToken, authorizationCode: authorizationCode, fullName: fullName, appleUserId: appleUserId), rootKey: nil)
    }

    public func confirmShip(orderIds: [String], addressId: String, keys: [String], couponId: String?) -> Observable<ConfirmShipEnvelope> {
        return request(.confirmShip(orderIds: orderIds, addressId: addressId, keys: keys, couponId: couponId), rootKey: nil)
    }

    public func queryPayOrder(outTradeNumber: String) -> Observable<QueryPayOrderEnvelope> {
        return request(.queryPayOrder(outTradeNumber: outTradeNumber), rootKey: nil)
    }

    public func exchangeMallProduct(mallProductId: String, addressId: String, buyCount: Int, couponId: String?) -> Observable<ConfirmShipEnvelope> {
        return request(.exchangeMallProduct(mallProductId: mallProductId, addressId: addressId, buyCount: buyCount, couponId: couponId), rootKey: nil)
    }

    public func signPayOrder(amount: Double, payMethod: String, payFrom: PayFrom = .normal, paymentPlanId: String?) -> Observable<PayOrderEnvelope> {
        return request(.signPayOrder(amount: amount, payMethod: payMethod, payFrom: payFrom.rawValue, paymentPlanId: paymentPlanId))
    }

    public func joinSignIn(type: String) -> Observable<PayOrderEnvelope> {
        return request(.joinSignIn(type: type))
    }

    public func login(loginType: String, certificate: String, password: String) -> Observable<LoginEnvelope> {
        return request(.login(loginType: loginType, certificate: certificate, password: password), rootKey: nil)
    }

    public func getTokenAndKeys(keyCount: Int) -> Observable<TokenAndKeysEnvelope> {
        return request(.getTokenAndKeys(keyCount: keyCount))
    }

    public func bizInit() -> Observable<BizInitEnvelope> {
        return request(.bizInit)
    }

    public func getGamePlayIntro() -> Observable<GameIntroInfoEnvelope> {
        return request(.getGamePlayIntro)
    }

    public func getNDMemberInfo() -> Observable<MemberInfoEnvelope> {
        return request(.getNDMemberInfo)
    }

    public func getIAPProduct(type: String) -> Observable<IAPProductEnvelope> {
        return request(.getIAPProduct(type: type))
    }

    /// 获取房间结果信息
    public func getRoomInfo(roomId: String) -> Observable<RoomInfoEnvelope> {
        return request(.getRoomInfo(roomId: roomId))
    }

    // MARK: - 元气赏
    public func getOnePieceTaskRecordList(sortBy: String, sequence: String, page: Int) -> Observable<YiFanShangRecordListEnvelope> {
        return request(.getOnePieceTaskRecordList(sortBy: sortBy, sequence: sequence, page: page))
    }

    public func getOnePieceTaskRecordDetail(onePieceTaskRecordId: String) -> Observable<YiFanShangDetailEnvelope> {
        return request(.getOnePieceTaskRecordDetail(onePieceTaskRecordId: onePieceTaskRecordId))
    }

    public func getOnePiecePurchaseRecord(page: Int) -> Observable<YiFanShangRecordEnvelope> {
        return request(.getOnePiecePurchaseRecord(page: page))
    }

    public func getOnePieceJoinRecord(onePieceTaskRecordId: String, page: Int) -> Observable<YiFanShangPurchaseRecordListEnvelope> {
        return request(.getOnePieceJoinRecord(onePieceTaskRecordId: onePieceTaskRecordId, page: page))
    }

    public func getOnePieceRules() -> Observable<YiFanShangRuleListEnvelope> {
        return request(.getOnePieceRules)
    }

    public func getMyOnePieceOrder(type: String, page: Int) -> Observable<YiFanShangRecordListEnvelope> {
        return request(.getMyOnePieceOrder(type: type, page: page))
    }

    public func getHomeSearchMachine(text: String, type: String) -> Observable<SearchEnvelope> {
        return request(.getHomeSearchMachine(text: text, type: type))
    }

    // MARK: - 首页改版
    /// 首页弹窗
    public func getPopupMenus() -> Observable<PopupMenusEnvelope> {
        return request(.getPopupMenus)
    }

    /// 首页标签
    public func getHomeMachineTags() -> Observable<HomeMachineTagEnvelope> {
        return request(.getHomeMachineTags)
    }

    /// 首页推荐头部数据
    public func getHomeMainPage() -> Observable<HomeRecommendHeadEnvelope> {
        return request(.getHomeMainPage)
    }

    /// 首页机台列表
    public func getHomeMachineList(type: String?, tagId: String?, sourceType: String?, page: Int) -> Observable<HomeMachineListEnvelope> {
        return request(.getHomeMachineList(type: type, tagId: tagId, sourceType: sourceType, page: page))
    }

    /// 专题详情
    public func getThemeMachineList(themeId: String) -> Observable<HomeThemeListEnvelope> {
        return request(.getThemeMachineList(themeId: themeId))
    }

    /// 热门专题换一换
    public func getChangeThemeMachineList(nextParams: HomeNextParams) -> Observable<HomeTheme> {
        return request(.getChangeThemeMachineList(nextParams: nextParams))
    }

    // MARK: - 优惠券
    public func getCouponsOfUser(type: String) -> Observable<CouponEnvelope> {
        return request(.getCouponsOfUser(type: type))
    }

    var core: MoyaProvider = MoyaProvider<GashaponmachineTarget>()

    // 默认只解析 data 里面的东西，涉及到操作的接口，请把 rootKey 设为 nil，并根据返回的 code 和 msg 判断操作成功或者失败
    private func request<M: Argo.Decodable>(_ api: GashaponmachineTarget, rootKey: String? = "data") -> Observable<M> where M == M.DecodedType {
        /// FIXME This is a hack way to generate a random key `t` for each request
        /// https://github.com/Moya/M oya/issues/1663
        ///
        generateAndSaveRandomKeyForEachRequest()

        return self.core
            .rx
            .request(api)
            .mapObject(type: M.self, rootKey: rootKey)
            .observeOn(MainScheduler.instance)
    }

    private func generateAndSaveRandomKeyForEachRequest() {
        let currentRandomKey = String.random(length: 5).md5
        AppEnvironment.userDefault.set(currentRandomKey, forKey: requestRandomKey)
        AppEnvironment.userDefault.synchronize()
    }
}

/// 接口列表
public protocol ServiceType {

    var currentRequestKey: String? { get }

    var accessToken: String? { get }

    init(accessToken: String?)

    func login(_ accessToken: String) -> Self

    func logout() -> Self

    func getBanners() -> Observable<BannersEnvelope>

    func getMachineList(tagId: String?, type: Int?, page: Int) -> Observable<MachineListEnvelope>

    // 新我的页面
    func getMyselfInfoV2() -> Observable<UserInfoEnvelope>
    // 用户个人信息页面
    func getPersonalInfo() -> Observable<PersonalInfoEnvelope>
    // 修改用户信息
    func changeUserNicknameOrAvatar(username: String?, imageKey: String?) -> Observable<ResultEnvelope>
    // 注销账号
    func destroyAccount() -> Observable<ResultEnvelope>
    // 旧我的页面
    func getMyselfInfo() -> Observable<UserInfo>
    // 旧充值列表
    func getRechargeList() -> Observable<RechargeEnvelope>
    // 新充值列表
    func getPaymentPlanList() -> Observable<PaymentPlanListEnvelope>

    func getAwardDetail(roomId: String) -> Observable<AwardDetailEnvelope>

    func getLuckyEggRecord(roomId: String) -> Observable<LuckyEggRecordEnvelope>

    func getShipAddressList(page: Int) -> Observable<ShipAddressListEnvelope>

    // 用户蛋槽列表 - 发货
    func getEggProductList(sourceType: Int?, type: Int?, page: Int) -> Observable<EggProductListEnvelope>

    // 用户蛋槽列表 - 蛋槽
    func getUserEggProducts(sourceType: Int, page: Int) -> Observable<UserEggProductEnvelope>

    func getUserExchangeEggProducts(sourceType: Int) -> Observable<EggExchangeListEnvelope>

    func getEggPointLog(page: Int) -> Observable<EggPointLogEnvelope>

    func getBalanceLog(page: Int) -> Observable<BalanceLogEnvelope>

    func exchangeEggPoints(orderIds: [String]) -> Observable<ExchangeEggPointEnvelope>

    func getUserGameRecord(userId: String) -> Observable<UserGameRecordEnvelope>

    func setShipAddressDefault(addressId: String) -> Observable<ResultEnvelope>

    func getShipList(status: Int, page: Int) -> Observable<ShipListEnvelope>
    
    func getShipCountAndWorth() -> Observable<ShipWorthEnvelope>

    func upsertShipAddress(addressId: String?, name: String?, phone: String?, province: String?, city: String?, district: String?, detail: String?) -> Observable<DeliveryAddress>

    func getShipAdddress(addressId: String) -> Observable<DeliveryAddressDetail>

    func getShipDetail(shipId: String) -> Observable<ShipDetailEnvelope>

    func loginByOAuth(OAuthType: String, installationId: String, code: String?, identityToken: String?, authorizationCode: String?, fullName: String?, appleUserId: String?) -> Observable<LoginEnvelope>

    func getShipInfo(orderIds: [String], keys: [String]) -> Observable<ShipInfoEnvelope>

    func confirmShip(orderIds: [String], addressId: String, keys: [String], couponId: String?) -> Observable<ConfirmShipEnvelope>

    /// 支付签名(原生)
    func signPayOrder(amount: Double, payMethod: String, payFrom: PayFrom, paymentPlanId: String?) -> Observable<PayOrderEnvelope>

    /// 支付宝签名(网页支付)
    func joinSignIn(type: String) -> Observable<PayOrderEnvelope>

    func queryPayOrder(outTradeNumber: String) -> Observable<QueryPayOrderEnvelope>

    func reportCrash(physicId: String, cause: String, detail: String, contact: String?) -> Observable<ResultEnvelope>

    func getMallInfoV2(page: Int) -> Observable<MallInfoV2Envelope>

    func getMallCollectionProductList(mallCollectionId: String, page: Int) -> Observable<MallCollectionProductListEnvelope>

    func getMallProductExchangeRecords(page: Int) -> Observable<MallProductExchangeRecordsEnvelope>

    func getMallProductDetail(mallProductId: String) -> Observable<MallProductDetailEnvelope>

    func exchangeMallProduct(mallProductId: String, addressId: String, buyCount: Int, couponId: String?) -> Observable<ConfirmShipEnvelope>

    func login(loginType: String, certificate: String, password: String) -> Observable<LoginEnvelope>

    func register(loginType: String, certificate: String, password: String, code: String) -> Observable<RegisterEnvelope>

    func getGameRecords(machineType: Int, page: Int) -> Observable<GameRecordEnvelope>

    func getFaq() -> Observable<FAQEnvelope>

    func getSortedMallProductList(categoryId: String, page: Int) -> Observable<MallProductListEnvelope>

    func getInvitationInfo() -> Observable<InvitationInfoEnvelope>

    func getInviteFriendsList(page: Int) -> Observable<InviteFriendsListEnvelope>

    func addInvitationCode(invitationCode: String) -> Observable<ResultEnvelope>

    func getExchangeInfo(mallProductId: String) -> Observable<ShipInfoEnvelope>

    func logoutRequest() -> Observable<ResultEnvelope>

    func getOccupyRechargeList(roomId: String) -> Observable<RechargeEnvelope>

    func confirmReceive(shipId: String) -> Observable<ResultEnvelope>

    func getDistinctExchangeRecords(page: Int) -> Observable<MallDistinctExchangeRecordsEnvelope>

    func getRandomDanmakus() -> Observable<RandomDanmakusEnvelope>

    func getNotificationList(page: Int) -> Observable<NotificationListEnvelope>

    func getStaticAssets() -> Observable<StaticAssetsEnvelope>

    func getClientLogReportKey() -> Observable<UploadEventKeyEnvelope>

    func reportUploadClientLogSuccess(key: String) -> Observable<ResultEnvelope>

    func getComposePathList(page: Int) -> Observable<ComposePathListEnvelope>

    func getComposePathDetail(composePathId: String) -> Observable<ComposePathDetailEnvelope>

    func getComposeRecordList(page: Int) -> Observable<ComposeRecordListEnvelope>

    func lockComposeOrders(composePathId: String, orderIds: [String]) -> Observable<ResultEnvelope>

    func composeProduct(composePathId: String) -> Observable<ResultEnvelope>

    func applyPromoCode(code: String) -> Observable<ResultEnvelope>

    func bizInit() -> Observable<BizInitEnvelope>

    func setVerifyCode(target: String, phone: String) -> Observable<ResultEnvelope>

    func bindPhone(phone: String, code: String) -> Observable<ResultEnvelope>

    func getGamePlayIntro() -> Observable<GameIntroInfoEnvelope>

    func getConvMsgList(page: Int) -> Observable<ChatMessageEnvelope>

    func sendConvMsg(type: String, content: String, metaImage: CGSize) -> Observable<ResultEnvelope>

    func getUnreadConvMsgCount() -> Observable<Int>

    func getTokenAndKeys(keyCount: Int) -> Observable<TokenAndKeysEnvelope>

    func getNDMemberInfo() -> Observable<MemberInfoEnvelope>

    func verifyInAppPurchase(productId: String, receipt: String) -> Observable<ResultEnvelope>

    func getIAPProduct(type: String) -> Observable<IAPProductEnvelope>

    /// 获取机台房间信息
    func getRoomInfo(roomId: String) -> Observable<RoomInfoEnvelope>

    // MARK: - 元气赏
    func getOnePieceTaskRecordList(sortBy: String, sequence: String, page: Int) -> Observable<YiFanShangRecordListEnvelope>

    func getOnePieceTaskRecordDetail(onePieceTaskRecordId: String) -> Observable<YiFanShangDetailEnvelope>

    func buyOnePieceAward(onePieceTaskRecordId: String, count: Int) -> Observable<PurchaseResultEnvelope>

    func buyOnePieceMagicAward(onePieceTaskRecordId: String, numbers: [String]) -> Observable<PurchaseResultEnvelope>

    func getOnePiecePurchaseRecord(page: Int) -> Observable<YiFanShangRecordEnvelope>

    func getOnePieceJoinRecord(onePieceTaskRecordId: String, page: Int) -> Observable<YiFanShangPurchaseRecordListEnvelope>

    func getOnePieceRules() -> Observable<YiFanShangRuleListEnvelope>

    func getMyOnePieceOrder(type: String, page: Int) -> Observable<YiFanShangRecordListEnvelope>

    // MARK: - 首页改版
    /// 首页弹窗
    func getPopupMenus() -> Observable<PopupMenusEnvelope>

    /// 首页签到
    func signIn(couponTemplateId: String?) -> Observable<ResultEnvelope>

    /// 首页查询
    func getHomeSearchMachine(text: String, type: String) -> Observable<SearchEnvelope>

    /// 首页标签
    func getHomeMachineTags() -> Observable<HomeMachineTagEnvelope>

    /// 首页推荐头部数据
    func getHomeMainPage() -> Observable<HomeRecommendHeadEnvelope>

    /// 首页机台列表
    func getHomeMachineList(type: String?, tagId: String?, sourceType: String?, page: Int) -> Observable<HomeMachineListEnvelope>

    /// 专题详情
    func getThemeMachineList(themeId: String) -> Observable<HomeThemeListEnvelope>

    /// 专题换一换
    func getChangeThemeMachineList(nextParams: HomeNextParams) -> Observable<HomeTheme>

    // MARK: - 优惠券
    /// 获取用户优惠券
    func getCouponsOfUser(type: String) -> Observable<CouponEnvelope>

    // MARK: - 分享
    /// 分享回调
    func invitationFriendSuccess(platform: String) -> Observable<ResultEnvelope>
}
