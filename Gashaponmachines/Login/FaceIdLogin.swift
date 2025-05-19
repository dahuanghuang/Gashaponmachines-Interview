import LocalAuthentication

class FaceID {

    static let shared = FaceID()

    let context = LAContext()

    var isFaceIDLoginEnable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    func login() {
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "验证 FaceID") { (success, err) in

                DispatchQueue.main.async {
                    if success {
//                        QLog.debug("success")
                    } else {
//                        QLog.error("error")
                    }
                }

            }
        } else {

        }
    }
}
