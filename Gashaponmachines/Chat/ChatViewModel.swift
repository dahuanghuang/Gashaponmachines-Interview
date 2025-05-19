import RxCocoa
import RxSwift
import RxSwiftExt
import MessageKit

typealias SendMessageParam = (type: String, content: String, metaImage: CGSize)

class ChatViewModel: PaginationViewModel<ChatMessage> {

    // 发送消息请求
    var sendMessage = PublishSubject<SendMessageParam>()
    // 消息发送完毕的响应
    var sendMessageResp = PublishSubject<ResultEnvelope>()

    // 获取上传图片Token
    var getUploadToken = PublishSubject<Int>()
    // 获取完毕后的响应
    var getUploadTokenResp = PublishSubject<TokenAndKeysEnvelope>()

    override init() {
        super.init()

        // 获取消息列表
        let messagesResponse = request
            .flatMapLatest { page in
                AppEnvironment.current.apiService.getConvMsgList(page: page).materialize()
            }
            .share(replay: 1)

        // 获取上传的Token
        let uploadTokenResponse = getUploadToken
            .flatMapLatest { keyCount in
                AppEnvironment.current.apiService.getTokenAndKeys(keyCount: keyCount).materialize()
            }
            .share(replay: 1)

        uploadTokenResponse
            .elements()
            .bind(to: getUploadTokenResp)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(request, messagesResponse.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.messages
                self.isEnd.accept(responseMachines.count < Constants.kDefaultPageLimit)
                return self.pageIndex == Constants.kDefaultPageIndex ? responseMachines : responseMachines + array
            }
            .sample(messagesResponse.elements())
            .bind(to: items)
            .disposed(by: disposeBag)

        Observable
            .merge(request.map { _ in true },
                   messagesResponse.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)

        // 发送消息请求
        let sendMessageResponse = sendMessage
            .flatMapLatest { param in
                AppEnvironment.current.apiService.sendConvMsg(type: param.type, content: param.content, metaImage: param.metaImage).materialize()
            }
            .share(replay: 1)

        sendMessageResponse.elements()
            .bind(to: sendMessageResp)
            .disposed(by: disposeBag)

        Observable.merge(
            messagesResponse.errors(),
            uploadTokenResponse.errors(),
            sendMessageResponse.errors()
            )
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)

    }
}
