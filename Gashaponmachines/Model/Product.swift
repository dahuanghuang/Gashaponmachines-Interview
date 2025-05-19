import Argo
import Curry
import Runes

public struct Product {
    var title: String?
    var icon: String?
    var images: [String]?
    var subTitle: String?
    var intros: [Intro]?
    var worth: String?
    var luckyProductTitle: String?
    var eggAmountTitle: String?
    struct Intro {
        var title: String?
        var introImages: [String]?
    }
}

extension Product: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Product> {
        return curry(Product.init)
            <^> json <|? "title"
            <*> json <|? "icon"
            <*> json <||? "images"
        	<*> json <|? "subTitle"
        	<*> json <||? "intros"
            <*> json <|? "worth"
            <*> json <|? "luckyProductTitle"
            <*> json <|? "eggAmountTitle"

    }
}

extension Product.Intro: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Product.Intro> {
        return curry(Product.Intro.init)
            <^> json <|? "title"
            <*> json <||? "introImages"
    }
}

// 蛋槽
public struct EggProduct {
    /// 商品名称
    var title: String
    /// 商品图片
    var image: String
    /// 商品价值多少蛋壳
    var worth: String?
    /// 扭蛋 icon
    var icon: String?
    /// 商品获取时间
    var expireDate: String
    /// 是否需要锁定
    var isLocked: String?
    /// 过期提示文字
    var tips: String?
    /// 游戏记录 id
    var orderId: String?
    /// 是否需要变红提示，0 不需要，1 需要
    var needWarning: Bool?
    /// 商品详情图片
    var introImages: [String]?
    /// 扭蛋商品下面的警告文字
    var bottomTips: String?
    /// 相同扭蛋商品聚合数量
    var productCount: Int?

    var collections: [Collection]?

    // MARK: - 自定义属性
    /// 随机ID
    var randomId: String?

    struct Collection {
        var key: String
        var title: String
        var image: String
    }
}

extension EggProduct.Collection: Hashable {
    public static func == (lhs: EggProduct.Collection, rhs: EggProduct.Collection) -> Bool {
        return lhs.title == rhs.title
            && lhs.key == rhs.key
        	&& lhs.image == rhs.image
    }
}

extension EggProduct: Hashable {
    public static func == (lhs: EggProduct, rhs: EggProduct) -> Bool {
        return lhs.title == rhs.title
            && lhs.image == rhs.image
            && lhs.worth == rhs.worth
            && lhs.expireDate == rhs.expireDate
            && lhs.orderId == rhs.orderId
    }
}

extension EggProduct.Collection: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<EggProduct.Collection> {
        let tmp = curry(EggProduct.Collection.init)
        return tmp
            <^> json <| "key"
            <*> json <| "title"
            <*> json <| "image"
    }
}

extension EggProduct: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<EggProduct> {
        let tmp = curry(EggProduct.init)
        let tmp1 = tmp
            <^> json <| "title"
            <*> json <| "image"
            <*> json <|? "worth"
        let tmp2 = tmp1
            <*> json <|? "icon"
            <*> json <| "expireDate"
            <*> json <|? "isLocked"
            <*> json <|? "tips"
        	<*> json <|? "orderId"
        return tmp2
            <*> (json <|? "needWarning" <|> (json <|? "needWarning").map(String.toBool))
        	<*> json <||? "introImages"
            <*> json <|? "bottomTips"
            <*> (json <|? "productCount" <|> (json <|? "productCount").map(String.toInt))
        	<*> json <||? "collections"
            <*> json <|? "randomId"
    }
}
