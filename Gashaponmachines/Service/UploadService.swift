import Qiniu

class UploadService {

    static let shared = UploadService()

    private let manager = QNUploadManager()

    func upload(data: Data, key: String, token: String, complete: @escaping QNUpCompletionHandler, progressHandler: QNUpProgressHandler? = nil) {
        let option = QNUploadOption(progressHandler: progressHandler)
        manager?.put(data, key: key, token: token, complete: complete, option: option)
    }

    func uploadFile(filePath: String, key: String, token: String, complete: @escaping QNUpCompletionHandler, progressHandler: QNUpProgressHandler? = nil) {
        let option = QNUploadOption(progressHandler: progressHandler)
        manager?.putFile(filePath, key: key, token: token, complete: complete, option: option)
    }
}
