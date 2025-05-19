import Moya
import Alamofire
import RxSwift
//import Result
import Argo

/// 这个枚举负责定义可以请求的 API
public enum GashaponmachineTarget {
    case register(loginType: String, certificate: String, password: String, code: String)
    case login(loginType: String, certificate: String, password: String)
	case getBanners
    case getMachineList(tagId: String?, type: Int?, page: Int)
    case getMachineListByTagId(tagId: String)
    // 新我的页面
    case getMyselfInfoV2
    // 用户信息页面
    case getPersonalInfo
    // 修改用户信息
    case changeUserNicknameOrAvatar(username: String?, imageKey: String?)
    // 注销账号
    case destroyAccount
    // 旧我的页面
    case getMyselfInfo
    // 旧充值列表
    case getRechargeList
    // 新充值列表
    case getPaymentPlanList
    case getAwardDetail(roomId: String)
    case getLuckyEggRecord(roomId: String)
    case getEggProductList(sourceType: Int?, type: Int?, page: Int)
    case getUserEggProducts(sourceType: Int, page: Int)
    case getUserExchangeEggProducts(sourceType: Int)
    case exchangEggPoints(orderIds: [String])
    case getUserGameRecord(userId: String)
    case getEggPointLog(page: Int)
    case getBalanceLog(page: Int)
    case getShipList(status: Int, page: Int)
    case getShipCountAndWorth
    case getShipDetail(shipId: String)
    case getShipAddressList(page: Int)
    case getShipAddress(addressId: String)
    case upsertShipAddress(addressId: String?, name: String?, phone: String?, province: String?, city: String?, district: String?, detail: String?)
    case setShipAddressDefault(addressId: String)
    case exchangeEggPoints(orderIds: [String])
    case loginByOAuth(OAuthType: String, installationId: String, code: String?, identityToken: String?, authorizationCode: String?, fullName: String?, appleUserId: String?)
    case getShipInfo(orderIds: [String], keys: [String])
    case confirmShip(orderIds: [String], addressId: String, keys: [String], couponId: String?)
    case signPayOrder(amount: Double, payMethod: String, payFrom: Int, paymentPlanId: String?)
    case joinSignIn(type: String)
    case queryPayOrder(outTradeNumber: String)
    case reportCrash(physicId: String, cause: String, detail: String, contact: String?)
    case getMallInfoV2(page: Int)
    case getMallCollectionProductList(mallCollectionId: String, page: Int)
    case getMallProductExchangeRecords(page: Int)
    case getSortedMallProductList(categoryId: String, page: Int)
    case getMallProductDetail(mallProductId: String)
    case exchangeMallProduct(mallProductId: String, addressId: String, buyCount: Int, couponId: String?)
    case getGameRecords(machineType: Int, page: Int)
    case getFAQ
    case addInvitationCode(invitationCode: String)
    case getInvitationInfo
    case getInviteFriendsList(page: Int)
    case getExchangeInfo(mallProductId: String)
    case logoutRequest
    case getOccupyRechargeList(roomId: String)
    case confirmReceive(shipId: String)
    case getDistinctExchangeRecords(page: Int)
    case getRandomDanmakus
    case getNotificationList(page: Int)
    case getStaticAssets
    case getClientLogReportKey
    case reportUploadClientLogSuccess(key: String)
    case getComposePathList(page: Int)
    case getComposePathDetail(composePathId: String)
	case getComposeRecordList(page: Int)
    case composeProduct(composePathId: String)
    case lockComposeOrders(composePathId: String, orderIds: [String])
    case applyPromoCode(code: String)
    case setVerifyCode(target: String, phone: String)
    case bindPhone(phone: String, code: String)
    case bizInit
    case getGamePlayIntro
    case getConvMsgList(page: Int)
    case getUnreadConvMsgCount
    case sendConvMsg(type: String, content: String, metaImage: CGSize)
    case getTokenAndKeys(keyCount: Int)
    case getNDMemberInfo
    case verifyInAppPurchase(productId: String, receipt: String)
    case getIAPProduct(type: String)
    case getRoomInfo(roomId: String)

    // MARK: - 元气赏
    case getOnePieceTaskRecordList(sortBy: String, sequence: String, page: Int)
    case getOnePieceTaskRecordDetail(onePieceTaskRecordId: String)
    case buyOnePieceAward(onePieceTaskRecordId: String, count: Int)
    case buyOnePieceMagicAward(onePieceTaskRecordId: String, numbers: [String])
    case getOnePiecePurchaseRecord(page: Int)
    case getOnePieceJoinRecord(onePieceTaskRecordId: String, page: Int)
    case getOnePieceRules
    case getMyOnePieceOrder(type: String, page: Int)

    // MARK: - 首页改版
    /// 首页弹窗
    case getPopupMenus
    /// 首页机台查询
    case getHomeSearchMachine(text: String, type: String)
    /// 首页标签
    case getHomeMachineTags
    /// 首页头部
    case getHomeMainPage
    /// 机台列表
    case getHomeMachineList(type: String?, tagId: String?, sourceType: String?, page: Int)
    /// 专题列表
    case getThemeMachineList(themeId: String)
    /// 热门专题换一换
    case getChangeThemeMachineList(nextParams: HomeNextParams)

    // MARK: - 优惠券
    case getCouponsOfUser(type: String)

    case invitationFriendSuccess(platform: String)

    // 签到
    case signIn(couponTemplateId: String?)
}

extension GashaponmachineTarget: TargetType {

    /// The target's base `URL`.
    public var baseURL: URL {
        return URL(string: Constants.kQUQQI_DOMAIN_URL)!
    }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        var str: String
        switch AppEnvironment.current.stage {
        case .stage:
            str = "/stage/0"
        case .test:
            str = "/dev/0"
        default:
            str = "/0"
        }

        switch self {
        case .logoutRequest:
            str += "/private/logout"
        case .register:
            str += "/public/register"
        case .login:
            str += "/public/login"
        case .getBanners:
            str += "/public/getBanners"
        case .getMachineListByTagId,
        	 .getMachineList:
            str += "/public/getMachineList"
        case .getMyselfInfoV2:
            str += "/private/getMyselfInfoV2"
        case .getPersonalInfo:
            str += "/private/getPersonalInfo"
        case .changeUserNicknameOrAvatar:
            str += "/private/changeUserNicknameOrAvatar"
        case .destroyAccount:
            str += "/private/destroyAccount"
        case .getMyselfInfo:
            str += "/private/getMyselfInfo"
        case .getRechargeList:
            str += "/private/getRechargeList"
        case .getPaymentPlanList:
            str += "/private/getPaymentPlanList"
        case .getAwardDetail:
            str += "/private/getAwardDetail"
        case .getLuckyEggRecord:
            str += "/private/getLuckyEggRecord"
        case .getEggProductList:
            str += "/private/getEggProductList"
        case .getUserEggProducts:
            str += "/private/getUserEggProducts"
        case .getUserExchangeEggProducts:
            str += "/private/getUserExchangeEggProducts"
        case .exchangEggPoints:
            str += "/private/exchangEggPoints"
        case .getUserGameRecord:
            str += "/private/getUserGameRecord"
        case .getShipAddressList:
            str += "/private/getShipAddressList"
        case .getEggPointLog:
            str += "/private/getEggPointLog"
        case .getBalanceLog:
            str += "/private/getBalanceLog"
        case .upsertShipAddress:
            str += "/private/upsertShipAddress"
        case .exchangeEggPoints:
            str += "/private/exchangeEggPoints"
        case .loginByOAuth:
            str += "/public/loginByOAuth"
        case .getShipList:
            str += "/private/getShipList"
        case .getShipCountAndWorth:
            str += "/private/getShipCountAndWorth"
        case .getShipAddress:
            str += "/private/getShipAddress"
        case .setShipAddressDefault:
            str += "/private/setShipAddressDefault"
        case .getShipDetail:
            str += "/private/getShipDetail"
        case .getShipInfo:
            str += "/private/getShipInfoV2"
        case .confirmShip:
            str += "/private/confirmShipV2"
        case .signPayOrder:
            str += "/private/signPayOrder"
        case .joinSignIn:
            str += "/private/joinSignIn"
        case .queryPayOrder:
            str += "/private/queryPayOrder"
        case .reportCrash:
            str += "/private/reportCrash"
        case .getMallInfoV2:
            str += "/private/getMallInfoV2"
        case .getMallCollectionProductList:
            str += "/private/getCollectionProductList"
        case .getMallProductExchangeRecords:
            str += "/private/getMallProductExchangeRecords"
        case .getMallProductDetail:
            str += "/private/getMallProductDetail"
        case .getSortedMallProductList:
            str += "/private/getSortedMallProductList"
        case .exchangeMallProduct:
        	str += "/private/exchangeMallProduct"
        case .getGameRecords:
            str += "/private/getGameRecords"
        case .getFAQ:
            str += "/public/getFaq"
        case .addInvitationCode:
            str += "/private/addInvitationCode"
        case .getInviteFriendsList:
            str += "/private/getInviteFriendsList"
        case .getInvitationInfo:
            str += "/private/getInvitationInfo"
        case .getExchangeInfo:
            str += "/private/getExchangeInfo"
        case .getOccupyRechargeList:
            str += "/private/getOccupyRechargeList"
        case .confirmReceive:
            str += "/private/confirmReceive"
        case .getDistinctExchangeRecords:
            str += "/private/getDistinctExchangeRecords"
        case .getRandomDanmakus:
            str += "/public/getRandomDanmakus"
        case .getNotificationList:
            str += "/private/getNotificationList"
        case .getStaticAssets:
            str += "/public/getStaticAssets"
        case .getClientLogReportKey:
            str += "/private/getClientLogReportKey"
        case .reportUploadClientLogSuccess:
    		str += "/private/reportUploadClientLogSuccess"
        case .getComposePathList:
            str += "/private/getComposePathList"
        case .getComposePathDetail:
            str += "/private/getComposePathDetail"
        case .getComposeRecordList:
            str += "/private/getComposeRecordList"
        case .lockComposeOrders:
            str += "/private/lockComposeOrders"
        case .composeProduct:
            str += "/private/composeProduct"
        case .applyPromoCode:
            str += "/private/applyPromoCode"
        case .setVerifyCode:
            str += "/private/setVerifyCode"
        case .bindPhone:
            str += "/private/bindPhone"
        case .bizInit:
            str += "/public/bizInit"
        case .getGamePlayIntro:
            str += "/public/getGamePlayIntro"
        case .getConvMsgList:
            str += "/private/getConvMsgList"
        case .getUnreadConvMsgCount:
            str += "/private/getUnreadConvMsgCount"
        case .sendConvMsg:
            str += "/private/sendConvMsg"
        case .getTokenAndKeys:
            str += "/public/getTokenAndKeys"
        case .getNDMemberInfo:
            str += "/private/getNDMemberInfo"
        case .verifyInAppPurchase:
            str += "/private/verifyInAppPurchase"
        case .getIAPProduct:
            str += "/private/getIAPProduct"
        case .getRoomInfo:
            str += "/private/getRoomInfo"
        case .getOnePieceTaskRecordList:
            str += "/private/getOnePieceTaskRecordList"
        case .getOnePieceTaskRecordDetail:
            str += "/private/getOnePieceTaskRecordDetail"
        case .buyOnePieceAward:
            str += "/private/buyOnePieceAward"
        case .buyOnePieceMagicAward:
            str += "/private/buyOnePieceMagicAward"
        case .getOnePiecePurchaseRecord:
            str += "/private/getOnePiecePurchaseRecord"
        case .getOnePieceJoinRecord:
            str += "/private/getOnePieceJoinRecord"
        case .getOnePieceRules:
            str += "/private/getOnePieceRules"
        case .getMyOnePieceOrder:
            str += "/private/getMyOnePieceOrder"
        case .getPopupMenus:
            str += "/private/getPopupMenus"
        case .getHomeSearchMachine:
            str += "/public/search"
        case .getHomeMachineTags:
            str += "/public/getMachineTags"
        case .getHomeMainPage:
            str += "/public/getMainPage"
        case .getHomeMachineList:
            str += "/public/getMachineList"
        case .getThemeMachineList:
            str += "/public/getMachineListWithTopic"
        case .getChangeThemeMachineList:
            str += "/public/getMachineListWithNextTopic"
        case .getCouponsOfUser:
            str += "/private/getCouponsOfUser"
        case .invitationFriendSuccess:
            str += "/private/invitationFriendSuccess"
        case .signIn:
            str += "/private/signIn"
        }

        return str
    }

    /// The HTTP method used in the request.
    public var method: Moya.Method {
        return .post
    }

    /// Provides stub data for use in testing.
    public var sampleData: Data {
        return "".data(using: .utf8)!
    }

    /// The type of HTTP task to be performed.
    public var task: Moya.Task {
        do {
            let data = try JSONSerialization.data(withJSONObject: self.parameters, options: [])
            return .requestCompositeData(bodyData: data, urlParameters: [:])
        } catch {
            return .requestPlain
        }
    }

    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    public var validate: Bool { return false }

    ///
    public var parameters: [String: Any] {
        var param: [String: Any] = [:]
        let limit = Constants.kDefaultPageLimit
        switch self {
        case let .getAwardDetail(roomId),
             let .getLuckyEggRecord(roomId):
            param["roomId"] = roomId
        case let.exchangEggPoints(orderIds):
            param["orderIds"] = orderIds
        case let .getUserGameRecord(userId):
            param["userId"] = userId
        case let .register(loginType, certificate, password, code):
            param["loginType"] = loginType
            param["certificate"] = certificate
            param["password"] = password
            param["code"] = code
        case let .login(loginType, certificate, password):
            param["loginType"] = loginType
            param["certificate"] = certificate
            param["password"] = password
        case let .getEggProductList(sourceType, type, page):
            if let type = type {
                param["type"] = type
            }
            param["page"] = page
            param["limit"] = 80
            if let sourceType = sourceType {
                param["sourceType"] = sourceType
            }
        case let .getUserEggProducts(sourceType, page):
            param["page"] = page
            param["limit"] = limit
            param["sourceType"] = sourceType
        case let .getUserExchangeEggProducts(sourceType):
            param["sourceType"] = sourceType
        case let .upsertShipAddress(addressId, name, phone, province, city, distinct, detail):
            if let addressId = addressId {
                param["addressId"] = addressId
            }
            if let name = name {
                param["name"] = name
            }
            if let phone = phone {
                param["phone"] = phone
            }
            if let province = province {
                param["province"] = province
            }
            if let city = city {
                param["city"] = city
            }
            if let distinct = distinct {
                param["district"] = distinct
            }
            if let detail = detail {
                param["detail"] = detail
            }
        case let .exchangeEggPoints(orderIds):
            param["orderIds"] = orderIds
        case let .loginByOAuth(OAuthType, installationId, code, identityToken, authorizationCode, fullName, appleUserId):
            param["OAuthType"] = OAuthType
            param["installationId"] = installationId
            if let c = code {
                param["code"] = c
            }
            if let token = identityToken {
                param["identityToken"] = token
            }
            if let authCode = authorizationCode {
                param["authorizationCode"] = authCode
            }
            if let fName = fullName {
                param["fullName"] = fName
            }
            if let id = appleUserId {
                param["appleUserId"] = id
            }
        case let .getShipList(status, page):
            param["status"] = status
            param["page"] = page
        case let .getShipAddress(addressId):
            param["addressId"] = addressId
        case let .setShipAddressDefault(addressId):
            param["addressId"] = addressId
        case let .getShipDetail(shipId):
            param["shipId"] = shipId
        case let .getShipInfo(orderIds, keys):
            param["orderIds"] = orderIds
            param["keys"] = keys
        case let .confirmShip(orderIds, addressId, keys, couponId):
            param["orderIds"] = orderIds
            param["addressId"] = addressId
            param["keys"] = keys
            if let id = couponId {
                param["couponId"] = id
            }
        case let .queryPayOrder(outTradeNumber):
            param["outTradeNumber"] = outTradeNumber
        case let .signPayOrder(amount, payMethod, payFrom, paymentPlanId):
            param["amount"] = amount * 100
            param["payMethod"] = payMethod
            param["payFrom"] = payFrom
            if let paymentId = paymentPlanId {
                param["paymentPlanId"] = paymentId
            }
        case let .joinSignIn(type):
            param["type"] = type
        case let .reportCrash(physicId, cause, detail, contact):
            param["physicId"] = physicId
            param["cause"] = cause
            param["detail"] = detail
            if let contact = contact, contact != "" {
                param["contact"] = contact
            }
        case let .getMallCollectionProductList(mallCollectionId, page):
            param["mallCollectionId"] = mallCollectionId
            param["page"] = page
            param["limit"] = 21
        case let .getMallProductDetail(mallProductId):
            param["mallProductId"] = mallProductId
        case let .exchangeMallProduct(mallProductId, addressId, buyCount, couponId):
            param["mallProductId"] = mallProductId
            param["addressId"] = addressId
            param["buyCount"] = buyCount
            if let id = couponId {
                param["couponId"] = id
            }
        case let .getSortedMallProductList(categoryId, page):
            param["page"] = page
            param["limit"] = limit
            param["categoryId"] = categoryId
        case let .addInvitationCode(invitationCode):
            param["invitationCode"] = invitationCode
        case let .getGameRecords(type, page):
            param["machineType"] = type
            param["page"] = page
            param["limit"] = limit
        case let .getMachineListByTagId(tagId):
            param["tagId"] = tagId
        case let .getMallProductExchangeRecords(page),
             let .getInviteFriendsList(page),
             let .getBalanceLog(page),
             let .getShipAddressList(page),
             let .getEggPointLog(page):
            param["page"] = page
            param["limit"] = limit
        case let .getMachineList(tagId, type, page):
            param["page"] = page
            param["limit"] = limit
            if let tagId = tagId {
                param["tagId"] = tagId
            }
            if let type = type {
                param["type"] = type
            }
        case let .getExchangeInfo(mallProductId):
            param["mallProductId"] = mallProductId
        case let .getOccupyRechargeList(roomId):
            param["roomId"] = roomId
        case let .confirmReceive(shipId):
            param["shipId"] = shipId
        case let .getMallInfoV2(page):
            param["page"] = page
            param["limit"] = 30
        case let .getDistinctExchangeRecords(page):
            param["page"] = page
            param["limit"] = limit
        case let .getNotificationList(page):
            param["page"] = page
            param["limit"] = limit
        case let .getComposePathList(page):
            param["page"] = page
            param["limit"] = limit
        case let .reportUploadClientLogSuccess(key):
            param["key"] = key
        case let .getComposePathDetail(pathId):
            param["composePathId"] = pathId
        case let .getComposeRecordList(page):
            param["page"] = page
        case let .composeProduct(composePathId):
            param["composePathId"] = composePathId
        case let .lockComposeOrders(composePathId, orderIds):
            param["composePathId"] = composePathId
            param["orderIds"] = orderIds
        case let .applyPromoCode(code):
            param["code"] = code
        case let .setVerifyCode(target, phone):
            param["target"] = target
            param["phone"] = phone
        case let .bindPhone(phone, code):
            param["phone"] = phone
            param["code"] = code
        case let .getConvMsgList(page):
            param["page"] = page
            param["limit"] = limit
        case let .sendConvMsg(type, content, metaImage):
            param["type"] = type
            param["content"] = content
            param["metaImage"] = ["width": metaImage.width, "height": metaImage.height]
        case let .getTokenAndKeys(keyCount):
            param["keyCount"] = keyCount
        case let .verifyInAppPurchase(productId, receipt):
            param["productId"] = productId
            param["receipt"] = receipt
        case let .getIAPProduct(type):
            param["type"] = type
        case let .getRoomInfo(roomId):
            param["roomId"] = roomId
        case let .getOnePieceTaskRecordList(sortBy, sequence, page):
            param["sortBy"] = sortBy
            param["sequence"] = sequence
            param["page"] = page
            param["limit"] = limit
        case let .getOnePieceTaskRecordDetail(onePieceTaskRecordId):
            param["onePieceTaskRecordId"] = onePieceTaskRecordId
        case let .buyOnePieceAward(onePieceTaskRecordId, count):
            param["onePieceTaskRecordId"] = onePieceTaskRecordId
            param["count"] = count
        case let .buyOnePieceMagicAward(onePieceTaskRecordId, numbers):
            param["onePieceTaskRecordId"] = onePieceTaskRecordId
            param["numbers"] = numbers
        case let .getOnePiecePurchaseRecord(page):
            param["page"] = page
            param["limit"] = limit
        case let .getOnePieceJoinRecord(onePieceTaskRecordId, page):
            param["page"] = page
            param["onePieceTaskRecordId"] = onePieceTaskRecordId
            param["limit"] = limit
        case let .getMyOnePieceOrder(type, page):
            param["type"] = type
            param["page"] = page
            param["limit"] = limit
        case let .getHomeSearchMachine(text, type):
            param["text"] = text
            param["type"] = type
        case let .getHomeMachineList(type, tagId, sourceType, page):
            if let type = type {
                param["type"] = Int(type)
            }
            if let tagId = tagId {
                param["tagId"] = tagId
            }
            if let sourceType = sourceType {
                param["sourceType"] = sourceType
            }
            param["page"] = page
            param["limit"] = limit
        case let .getThemeMachineList(themeId):
            param["topicId"] = themeId
        case let .getChangeThemeMachineList(nextParams):
            if let limit = nextParams.limit, let intLimit = Int(limit) {
                param["limit"] = intLimit
            }
            if let machineTopicId = nextParams.machineTopicId {
                param["machineTopicId"] = machineTopicId
            }
            if let machineIds = nextParams.machineIds {
                param["machineIds"] = machineIds
            }
        case let .getCouponsOfUser(type):
            param["tab"] = type
        case let .invitationFriendSuccess(platform):
            param["platform"] = platform
        case let .signIn(couponTemplateId):
            if let id = couponTemplateId {
                param["couponTemplateId"] = id
            }
        case let .changeUserNicknameOrAvatar(username, imageUrl):
            if let newNickname = username {
                param["newNickname"] = newNickname
            }
            if let newAvatar = imageUrl {
                param["newAvatar"] = newAvatar
            }
        default:
            break
        }

        param["t"] = AppEnvironment.current.apiService.currentRequestKey

        param["deviceInfo"] = DeviceInfo.deviceInfo()["deviceInfo"]

        // 上传网络日志
        LogService.shared.uploadHTTPRequestLog(path: path, params: param)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: param, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let result = QUEncryption.encrypt(withText: jsonString) ?? ""
                return ["p": result]
            }
        } catch {
            QLog.error("paramDict转data失败")
        }

        return param
    }

    /// The headers to be used in the request.
    public var headers: [String: String]? {

        // 自己写的
//        do {
//            let bodyData = try JSONSerialization.data(withJSONObject: self.parameters, options: [])
//            let builder = AliCloudGatewayHelper()
//            let dict = builder.buildHeader("https",
//                                           method: self.method.rawValue,
//                                           host: self.baseURL.host!,
//                                           path: self.path,
//                                           pathParams: nil,
//                                           queryParams: nil,
//                                           formParams: nil,
//                                           body: bodyData,
//                                           requestContentType: CLOUDAPI_CONTENT_TYPE_JSON,
//                                           acceptContentType: CLOUDAPI_CONTENT_TYPE_JSON,
//                                           headerParams: nil)
//
//            return dict.allHTTPHeaderFields
//        } catch {
//            return nil
//        }

//        // 官方的
        let request = CACommonRequest(path: self.path, withMethod: self.method.rawValue, withHost: self.baseURL.host!, isHttps: true)!
        //            request.setBody(bodyData, withContentType: CA_CONTENT_TYPE_JSON)

        let client = CAClient.init()
        client?.setAppKeyAndAppSecret(apiGatewayAppKey, appSecret: apiGatewayAppSecret)
        request.sign(with: client)

        let headers = request.buildHttpRequest()?.allHTTPHeaderFields

        return headers
    }
}

private let apiGatewayAppKey = "123"
private let apiGatewayAppSecret = "123"

/*
 官方:
 
 "Date": "Tue, 30 Mar 2021 15:38:13 GMT+8",
 "X-Ca-Timestamp": "1617089893019",
 "X-Ca-Nonce": "813DF375-6417-4F43-9847-F54BF2196494",
 "User-Agent": "CA_iOS_SDK_2.0",
 "Host": "https.quqqi.com",
 "X-Ca-Key": "24613452",
 "X-Ca-Version": "1",
 "Content-Type": "application/json; charset=UTF-8",
 "Accept": "application/json",
 "X-Ca-Signature-Headers": "X-Ca-Key,X-Ca-Nonce,X-Ca-Signature-Method,X-Ca-Timestamp,X-Ca-Version",
 "X-Ca-Signature": "I8HlmPkuNuWvqQH9strugfNktavs8zbQIGAICdcYO2A=",
 
 "X-Ca-Signature-Method": "HmacSHA256",
 */

/*
 我的:
 
  "Date": "Tue, 30 Mar 2021 16:30:49 GMT+8", ✅1
  "X-Ca-Timestamp": "1617093049001", ✅2
  "X-Ca-Nonce": "111109F6-D5AF-4C68-BBC1-EA28228A196F", ✅3
  "User-Agent": "YQND-iOS-Client", ✅4
  "Host": "https.quqqi.com", ✅5
  "X-Ca-Key": "24613452", ✅6
  "X-Ca-Version": "1", ✅7
  "Content-Type": "application/json; charset=UTF-8", ✅8
  "Accept": "application/json; charset=UTF-8", ✅9
  "X-Ca-Signature-Headers": "X-Ca-Version,X-Ca-Nonce,X-Ca-Timestamp,X-Ca-Key" ✅10
  "X-Ca-Signature": "tKQxGXPy0GPKLmBqDTeV5+zURhpoFcXliStzoMkhXig=", ✅11
 */

/*
 Flutter:
 
 Date: 2021-03-31 15:29:06.159,
 X-Ca-Timestamp: 1617175746159,
 X-Ca-Nonce: ,
 User-Agent: YQND-iOS-Client,
 Host: https.quqqi.com,
 X-Ca-Key: 24613452,
 X-Ca-Version: 1,
 Content-Type: application/json; charset=UTF-8,
 Accept: application/json; charset=UTF-8,
 X-Ca-Stage: RELEASE,❌
 X-Ca-Signature-Headers: X-Ca-Timestamp,X-Ca-Nonce,X-Ca-Key,X-Ca-Version,X-Ca-Stage,X-Ca-Signature-Headers,❌
 X-Ca-Signature: o4pWwvZdUnOPvNqNHJNRsPy5mamo2tNTHXYfOr/Rq7Y=
 */

/*
a0bcdfa3a49769e671161c671b22a9ba5cce576b39743f5e6ba44bb63fb0cec5fab456fb56c1fbeffee95fa0a0f510ffdd98dbd24d3ac9ff5c1a8b29e218636af3d3ac2d69212c0345ff9fa9ee9cfd1b8638a2b8c5be39cec782991bc0caf5e4212ed73946b91c852f950c2d13a2d795c09dea6da98024da2a5985a2a86671c342e9097f6d8759d5ba693bba768e5fd86d8297e90d9b39362cf42a66ed86cc9e52c5dbbe0a3dd33cb54c82bb40904863d1e7201eb1e0e483c79cdb0b82acca579426ec16f6f73ea1e4911b02919109214d7e3fda355d125a34801aaf8921682131cfdc34b52b5983f6b9f74ecac6a11f6d89b57bfbafb6bc6529fca518292da3bc0912536c3695ffe29c979950eccdf5b427f1c3fcea4e9f012aa323f60eb4df
 
 
 {
 channel: AppStore,
 app_version: 1.0.0,
 deviceId: 46739A84-0A00-4A3C-BAD1-EB8D6DAE0F14,
 os: iOS,
 app_build_version: 1,
 idfa: 00000000-0000-0000-0000-000000000000,
 is_jailbroken: 0,
 os_version: Version 14.4 (Build 18D46),
 package_name: 元气扭蛋
 
 }
 
 
 {
 channel: AppStore,
 app_version: 2.9.100,
 deviceId: 3FC96A7D-37F8-467F-B937-8AEDBCFFD1C5,
 os: iOS,
 app_build_version: 11258,
 idfa: 66450387-B7F8-4B34-A992-36DD887BC6F7,
 is_jailbroken: 0,
 os_version: Version 14.3 (Build 18C66),
 package_name: 元气扭蛋
 },
 
 t: 5a399f8f7c474c9bffecbc440372f36b
 
 */
