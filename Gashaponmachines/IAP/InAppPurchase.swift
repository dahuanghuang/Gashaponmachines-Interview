import UIKit
import SwiftyStoreKit

protocol InAppPurchaseDelegate: class {

    func willSendReceiptToServer(productId: String, receipt: String, transaction: PaymentTransaction)
}

class InAppPurchase: NSObject {

    var receipt: String? {
        if let data = SwiftyStoreKit.localReceiptData {
            return data.base64EncodedString(options: [])
        }
        return nil
    }

    static let shared = InAppPurchase()

    weak var delegate: InAppPurchaseDelegate?

    func purchase(productId: String) {
        HUD.shared.persist(text: "购买中... 请稍候")
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { [weak self] result in
            switch result {
            case .success(let purchase):
                // 本地保存 receipt
                QLog.debug("Request Purchase Success: \(purchase.productId)")
                self?.verifyReceipt(productId: purchase.productId, transaction: purchase.transaction)
            case .error(let error):
                HUD.shared.dismiss()

                switch error.code {
                case .unknown:
                    QLog.debug("Unknown error. Please contact support")
                    HUD.showError(second: 2, text: "Unknown error. Please contact support", completion: nil)
                case .clientInvalid:
                    QLog.debug("Not allowed to make the payment")
                    HUD.showError(second: 2, text: "Not allowed to make the payment", completion: nil)
                case .paymentCancelled:
                    QLog.debug("paymentCancelled")
                    HUD.shared.dismiss()
                case .paymentInvalid:
                    QLog.debug("The purchase identifier was invalid")
                    HUD.showError(second: 2, text: "The purchase identifier was invalid", completion: nil)
                case .paymentNotAllowed:
                    QLog.debug("The device is not allowed to make the payment")
                    HUD.showError(second: 2, text: "The device is not allowed to make the payment", completion: nil)
                case .storeProductNotAvailable:
                    QLog.debug("The product is not available in the current storefront")
                    HUD.showError(second: 2, text: "The product is not available in the current storefront", completion: nil)
                case .cloudServicePermissionDenied:
                    QLog.debug("Access to cloud service information is not allowed")
                    HUD.showError(second: 2, text: "Access to cloud service information is not allowed", completion: nil)
                case .cloudServiceNetworkConnectionFailed:
                    QLog.debug("Could not connect to the network")
                    HUD.showError(second: 2, text: "Could not connect to the network", completion: nil)
                case .cloudServiceRevoked:
                    QLog.debug("User has revoked permission to use this cloud service")
                    HUD.showError(second: 2, text: "User has revoked permission to use this cloud service", completion: nil)
                default:
                    QLog.error("Unknown error from InAppPurchase")
                }
            }
        }
    }

    func verifyReceipt(productId: String, transaction: PaymentTransaction) {

        guard let receipt = self.receipt else {
            HUD.shared.dismiss()
            HUD.showError(second: 2, text: "无效的 receipt", completion: nil)
            return
        }

        self.delegate?.willSendReceiptToServer(productId: productId, receipt: receipt, transaction: transaction)

        // 本地测试
        #if DEBUG
        let validator = AppleReceiptValidator(service: .sandbox)
        SwiftyStoreKit.verifyReceipt(using: validator, forceRefresh: true, completion: { (result) in
            switch result {
            case .success(let receipt):
                // 本地校验
                if let status = receipt["status"] as? Int, status == 0 {
                    QLog.debug("Verify success")
                }
                break
            case .error(let error):
                QLog.error(error.localizedDescription)
                break
            }
        })
        #endif
    }

    func restorePurchase() {

        SwiftyStoreKit.restorePurchases { (purchases) in

        }
    }

    func completeIAPTransactions() {

        SwiftyStoreKit.completeTransactions { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                case .failed, .purchasing, .deferred:
                    QLog.error("failed purchasing deferred")
                    HUD.showError(second: 2, text: "CompleteTransaction Failed", completion: nil)
                    break
                }
            }
        }
    }
}
