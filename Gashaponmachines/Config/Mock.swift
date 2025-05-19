extension LoginEnvelope {

    private static let LoginEnvelopeSessionToken = "123"

    /// 模拟器无法登陆时请替换新的 sessionToken
    // efb89103-d44e-4fe5-aeb0-9694428fe464
    static var mockLoginEnvelope = LoginEnvelope(code: "0", msg: "Msg from mockLoginEnvelope", sessionToken: LoginEnvelope.LoginEnvelopeSessionToken, user: User.mockUser, isNew: "1", fromAd: "")
}

extension User {
    static var mockUser = User(uid: "999999", _id: "5abe08dd1f1e4f215e0783a2", username: "TestUser", nickname: "Test", avatar: "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJo2GbG4LiaF5YNwjGKLc3uT1UicPbUqlKhn7GuzyiaTdG89BLqqLialkkX6NT2NNSR6Dd9W8wJHibIHSA/132", avatarFrame: "https://sscdn.quqqi.com/2020/09/27/web/101538496_b7bf8613.png")
}
