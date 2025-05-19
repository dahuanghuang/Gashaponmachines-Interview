import Foundation
import RxDataSources
import RxCocoa
import RxSwift
import MJRefresh
import MessageKit
import InputBarAccessoryView
import SwiftDate
import Agrume

extension UIImagePickerController {

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

class ChatViewControlelr: MessagesViewController, Refreshable {

    static let topSectionInset: CGFloat = 16
    static let bottomSectionInset: CGFloat = 4

    let vm: ChatViewModel = ChatViewModel()

    lazy var selectImgButton: ChatSendImageButton = {
        let btn = ChatSendImageButton()
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(selectImageAlbum), for: .touchUpInside)
        return btn
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    private var messages: [ChatMessage] = []

    let disposeBag = DisposeBag()

    /// 图片按钮
    lazy var sendImageButton: InputBarButtonItem = {
        let btn = ChatSendImageButton()
            .configure {
                $0.layer.cornerRadius = 22
                $0.layer.masksToBounds = true
                $0.spacing = .fixed(44)
                $0.setSize(CGSize(width: 44, height: 44), animated: false)
            }.onTouchUpInside { [weak self] _ in
                self?.selectImageAlbum()
            }
        return btn
    }()
    
    /// 发送按钮
    lazy var sendTextButton: InputBarButtonItem = {
        let btn = ChatSendTextButton()
            .configure {
                $0.layer.cornerRadius = 22
                $0.layer.masksToBounds = true
                $0.setSize(CGSize(width: 56, height: 44), animated: false)
            }.onTouchUpInside { _ in
                self.vm.sendMessage.onNext(SendMessageParam(type: ChatMessageType.text.rawValue, content: self.messageInputBar.inputTextView.text, metaImage: CGSize.zero))
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        return btn
    }()

    var refreshHeader: MJRefreshHeader?

    var uploadImgs: [UIImage] = []

    // MARK: - 系统函数
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        messagesCollectionView.scrollToBottom(animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshHeader = initRefreshHeader(.chat, scrollView: messagesCollectionView) { [weak self] in
            guard let self = self else { return }
            if self.vm.isEnd.value {
                self.refreshHeader?.endRefreshing()
            } else {
                self.vm.loadNextPageTrigger.onNext(())
            }
        }

        setupUI()

        vm.refreshTrigger.onNext(())

        bindViewModel()
    }

    // MARK: - 初始化函数
    func setupUI() {
        let navBar = CustomNavigationBar()
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        let titleLb = UILabel.with(textColor: .black, boldFontSize: 34, defaultText: "客服留言")
        titleLb.textAlignment = .left
        navBar.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(52)
            make.bottom.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
            make.width.equalTo(100)
        }
        
        let refreshIv = UIImageView(image: UIImage(named: "chat_refresh"))
        refreshIv.isUserInteractionEnabled = true
        refreshIv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshChatMessages)))
        navBar.addSubview(refreshIv)
        refreshIv.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(titleLb)
            make.size.equalTo(24)
        }
        
        
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        
        // input bar
        messageInputBar.delegate = self

        messageInputBar.setLeftStackViewWidthConstant(to: 44, animated: false)
        messageInputBar.setStackViewItems([sendImageButton], forStack: .left, animated: false)
        messageInputBar.setStackViewItems([sendTextButton], forStack: .right, animated: false)
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageInputBar.backgroundColor = UIColor.viewBackgroundColor
        messageInputBar.textViewPadding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -56)
        messageInputBar.inputTextView.textColor = .black
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.layer.cornerRadius = 22
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 56 + 12)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 0)
        messageInputBar.inputTextView.placeholderLabel.text = "新消息"
        messageInputBar.separatorLine.removeFromSuperview()
        messageInputBar.sendButton.configure {
            $0.backgroundColor = .qu_yellow
            $0.title = "发送"
            $0.setTitleColor(.qu_black, for: .normal)
            $0.setTitleColor(.qu_black, for: .disabled)
            $0.titleLabel?.font = UIFont.withPixel(28)
            $0.setSize(CGSize(width: 52, height: 36), animated: false)
            $0.layer.cornerRadius = 18
            $0.layer.masksToBounds = true
        }

        // layout
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = CGSize(width: 40, height: 40)
            layout.textMessageSizeCalculator.incomingAvatarSize = CGSize(width: 40, height: 40)
            layout.setMessageIncomingAvatarSize(CGSize(width: 40, height: 40))
            layout.setMessageOutgoingAvatarSize(CGSize(width: 40, height: 40))
        }
        messagesCollectionView.backgroundColor = .new_backgroundColor
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.register(ChatDateHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)

        
    }

    func bindViewModel() {
        // 消息列表获取
        vm.items
            .subscribe(onNext: { [weak self] items in
                self?.messages = items
                self?.messagesCollectionView.reloadData()
                if items.count <= Constants.kDefaultPageLimit {
                    self?.messagesCollectionView.scrollToBottom(animated: false)
                }
            })
            .disposed(by: disposeBag)

        vm.error
            .subscribe(onNext: { env in
                self.refreshHeader?.endRefreshing()
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)

        self.vm.items
            .mapTo(())
            .subscribe(onNext: { [weak self] in
                self?.refreshHeader?.endRefreshing()
            })
            .disposed(by: disposeBag)

        // 消息发送后响应结果
        vm.sendMessageResp
            .subscribe(onNext: { [weak self] env in
                self?.messageInputBar.inputTextView.text = nil
                self?.vm.refreshTrigger.onNext(())
            })
            .disposed(by: disposeBag)

        vm.getUploadTokenResp
            .subscribe(onNext: { [weak self] env in
                guard let self = self else { return }
                zip(self.uploadImgs, env.keys).map { (image: $0.0, key: $0.1)}.forEach { pair in
                    // 压缩
                    guard let data = pair.image.jpegData(compressionQuality: 0.3) else { return }
                    HUD.shared.persist(text: "上传中...")
                    // 上传七牛
                    UploadService.shared.upload(data: data, key: pair.key, token: env.token, complete: { (info, key, resp) in
                        HUD.shared.dismiss()
                        if let returnkey = key, let info = info, info.statusCode == 200 {
                            // 发送消息
                            self.vm.sendMessage.onNext(SendMessageParam(type: ChatMessageType.image.rawValue, content: returnkey, metaImage: pair.image.size))
                        } else {
                            QLog.error("上传失败")
                        }
                    }, progressHandler: nil)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 监听函数
    @objc func loadMoreMessage() {
        self.vm.loadNextPageTrigger.onNext(())
    }

    @objc func selectImageAlbum() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func refreshChatMessages() {
        vm.refreshTrigger.onNext(())
    }
}

extension ChatViewControlelr: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        self.view.endEditing(true)
    }

    // 原生的只支持发送一张图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        guard let img = image else {
            HUD.showError(second: 2, text: "图片信息有误，请重新选择", completion: nil)
            picker.dismiss(animated: true, completion: nil)
            return
        }
        self.uploadImgs = [img]
        self.vm.getUploadToken.onNext(1)
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewControlelr: MessageCellDelegate {

    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let ip = messagesCollectionView.indexPath(for: cell) else { return }
        let msg = messages[ip.section]
        if msg.type == .image, let url = msg.url {
            let agrume = Agrume(url: url)
            agrume.show(from: self)
        }
    }
}

extension ChatViewControlelr: InputBarAccessoryViewDelegate {
}

extension ChatViewControlelr: MessagesDataSource {

    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let header = messagesCollectionView.dequeueReusableHeaderView(ChatDateHeaderView.self, for: indexPath)
        header.dateLabel.text = ChatDateFormatter.shared.string(from: messages[indexPath.section].sentDate)
        return header
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber]
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let msg = messages[indexPath.section]
        imageView.gas_setImageWithURL(msg.url?.absoluteString)
    }

    func isFromCurrentSender(message: MessageType) -> Bool {
        return (message as? ChatMessage)?.direction == "SEND" ? true : false
    }

    func currentSender() -> SenderType {
        return Sender(id: AppEnvironment.current.apiService.accessToken ?? "currentSender", displayName: "")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: ChatViewControlelr.topSectionInset, left: ChatViewControlelr.bottomSectionInset, bottom: 4, right: 0)
    }

    private func isTimeLabelVisible(at section: Int) -> Bool {
        // 与上一次显示的时间对比，若这次时间离上一个显示时间大于5分钟，则显示
        if section == 0 {
            return true
        }
        let sentDate = messages[section].sentDate
        let lastSentDate = messages[section-1].sentDate
        if let mins = (sentDate - lastSentDate).minute, mins >= 5 {
            return true
        }
        return false
    }

//    private func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
//        guard indexPath.section - 1 >= 0 else { return false }
//        return messages[indexPath.section].sender == messages[indexPath.section - 1].sender
//    }
}

extension ChatViewControlelr: MessagesLayoutDelegate {

    /// 头部时间Lb的size
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        if isTimeLabelVisible(at: section) {
            return CGSize(width: Constants.kScreenWidth, height: UIFont.withPixel(24).lineHeight + ChatViewControlelr.topSectionInset + ChatViewControlelr.bottomSectionInset)
        }
        return .zero
    }
}

extension ChatViewControlelr: MessagesDisplayDelegate {

    /// 展示头像
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let msg = messages[indexPath.section]
        avatarView.gas_setImageWithURL(msg.avatar)
    }

    /// 消息的背景色
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return (message as? ChatMessage)?.direction == "SEND" ? .qu_yellow : .white
    }

    /// 消息颜色
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .qu_black
    }
}
