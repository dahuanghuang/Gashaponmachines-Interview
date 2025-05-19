import Argo
import Runes
import Curry

public struct StaticAssetsEnvelope {
    var bottomTab: [TabAssets]?

    var newBottomTab: [TabAssets]?

    var paymentOptions: [OccupyRechargeChoices]?

    var paymentMethods: [PaymentMethod]?
    /// 首页顶部背景
    var indexRoof: String?
    /// 首页banner背景
    var bannerBackground: String?
    /// 元气赏页顶部背景
    var onePieceRoof: String?
    /// 商城页顶部背景
    var mallRoof: String?

    var selfBackground: String?

    var flashLightsLeft: String?

    var flashLightsRight: String?

    var playButton: String?

    var playFlash: String?

    var playSpinner: String?

    var playSpinnerDark: String?

    var openScreenPicture: String?

    public struct TabAssets {
        let index: String?
        let title: String?
        let image_selected: String?
        let image_unselect: String?
        let updateAt: String?
    }

    public struct OccupyRechargeChoices {
        var priceLimit: String
        var options: [PaymentOption]
    }
}

extension StaticAssetsEnvelope: PropertyReflectable {}

extension StaticAssetsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<StaticAssetsEnvelope> {
        return curry(StaticAssetsEnvelope.init)
            <^> json <||? "bottomTab"
            <*> json <||? "newBottomTab"
        	<*> json <||? "occupyRechargeChoices"
        	<*> json <||? "paymentMethods"
            <*> json <|? "indexRoof"
            <*> json <|? "bannerBackground"
            <*> json <|? "onePieceRoof"
            <*> json <|? "mallRoof"
            <*> json <|? "selfBackground"
            <*> json <|? "flashLightsLeft"
            <*> json <|? "flashLightsRight"
        	<*> json <|? "playButton"
        	<*> json <|? "playFlash"
        	<*> json <|? "playSpinner"
            <*> json <|? "playSpinnerDark"
        	<*> json <|? "openScreenPicture"
    }
}

extension StaticAssetsEnvelope.OccupyRechargeChoices: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<StaticAssetsEnvelope.OccupyRechargeChoices> {
        return curry(StaticAssetsEnvelope.OccupyRechargeChoices.init)
            <^> json <| "priceLimit"
            <*> json <|| "choices"
    }
}

extension StaticAssetsEnvelope.TabAssets: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<StaticAssetsEnvelope.TabAssets> {
        return curry(StaticAssetsEnvelope.TabAssets.init)
            <^> json <|? "index"
        	<*> json <|? "title"
        	<*> json <|? "image_light" //  选中
            <*> json <|? "image_dark"  //  未选中
        	<*> json <|? "updateAt"
    }
}
