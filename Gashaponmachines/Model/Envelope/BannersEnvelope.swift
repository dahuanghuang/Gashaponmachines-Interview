import Argo
import Curry
import Runes

public struct BannersEnvelope {
    var banners: [Banner]
    var notices: [String]
    var tagList: [Tag]?
    var machineTypeList: [MachineType]?
    var icons: [Icon]?

    struct Tag {
        var title: String
        var tagId: String
    }

    struct MachineType {
        var type: String
        var name: String
    }

    struct Icon {
        var title: String
        var image: String
        var action: String
    }
}

extension BannersEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BannersEnvelope> {
        return curry(BannersEnvelope.init)
        	<^> json <|| "banners"
        	<*> json <|| "recentRecords"
        	<*> json <||? "machineTagList"
        	<*> json <||? "machineTypeList"
        	<*> json <||? "icons"
    }
}

extension BannersEnvelope.Tag: Equatable {
}

extension BannersEnvelope.Tag: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BannersEnvelope.Tag> {
        return curry(BannersEnvelope.Tag.init)
            <^> json <| "title"
        	<*> json <| "tagId"
    }
}

extension BannersEnvelope.MachineType: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BannersEnvelope.MachineType> {
        return curry(BannersEnvelope.MachineType.init)
            <^> json <| "type"
            <*> json <| "name"
    }
}

extension BannersEnvelope.Icon: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BannersEnvelope.Icon> {
        return curry(BannersEnvelope.Icon.init)
            <^> json <| "title"
            <*> json <| "image"
        	<*> json <| "action"
    }
}
