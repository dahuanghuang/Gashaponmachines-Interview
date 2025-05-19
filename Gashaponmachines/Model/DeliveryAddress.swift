import Argo
import Curry
import Runes

public struct DeliveryAddress {
    var addressId: String
    var name: String
    var phone: String
    var address: String
    var isDefault: String?
}

extension DeliveryAddress: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<DeliveryAddress> {
        let t = curry(DeliveryAddress.init)
        let t1 = t
            <^> json <| "addressId"
        	<*> json <| "name"
            <*> json <| "phone"
        return t1
            <*> json <| "address"
            <*> (json <|? "isDefault" <|> pure("false"))
    }
}

public struct DeliveryAddressDetail {
    var name: String
    var phone: String
    var provinceCode: String    // 省份编码
    var cityCode: String        // 城市编码
    var districtCode: String    // 区编码
    var provinceName: String    // 省份名称
    var cityName: String        // 城市名称
    var districtName: String    // 区名称
    var detail: String          // 区下面细分地址
    var isDefault: String       // 是否是默认地址，1 为是，0 为不是
    var addressId: String       // 收货地址 id
}

extension DeliveryAddressDetail: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<DeliveryAddressDetail> {
        let t = curry(DeliveryAddressDetail.init)
        let t1 = t
            <^> json <| "name"
            <*> json <| "phone"
            <*> json <| "provinceCode"
        let t2 = t1 <*> json <| "cityCode"
            <*> json <| "districtCode"
            <*> json <| "provinceName"
        let t3 = t2
            <*> json <| "cityName"
            <*> json <| "districtName"
            <*> json <| "detail"
        return t3
            <*> (json <| "isDefault" <|> pure("false"))
            <*> json <| "addressId"
    }
}
