import SwiftyStoreKit
import Alamofire

class AppleReceiptValidator: ReceiptValidator {

    public init(service: VerifyReceiptURLType = .appstoreProduction) {
        self.service = service
    }

    private let service: VerifyReceiptURLType

    func validate(receiptData: Data, completion: @escaping (VerifyReceiptResult) -> Void) {

        guard let receiptData = SwiftyStoreKit.localReceiptData else {
            HUD.showError(second: 2, text: "ReceiptData is nil", completion: nil)
            return
        }
        let receiptString = receiptData.base64EncodedString(options: [])
        let param = ["receipt-data": receiptString]
        AF.request(service.rawValue, method: HTTPMethod.post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { (response: AFDataResponse<Any>) in
                switch response.result {
                case .success(let value):
                    completion(.success(receipt: value as! ReceiptInfo))
                case .failure:
                    completion(.error(error: .receiptInvalid(receipt: [:], status: .none)))
                }
        }
    }

    public enum VerifyReceiptURLType: String {
        case appstoreProduction = "https://buy.itunes.apple.com/verifyReceipt"
        case sandbox            = "https://sandbox.itunes.apple.com/verifyReceipt"
    }
}
