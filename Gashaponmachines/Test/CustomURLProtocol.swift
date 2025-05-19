import UIKit

let CustomURLProtocolHandledKey = "CustomURLProtocolHandledKey"

class CustomURLProtocol: URLProtocol {

    var session: URLSession?

    // 方法 1：在拦截到网络请求后会调用这一方法，可以再次处理拦截的逻辑，比如设置只针对 http 和 https 的请求进行处理。
    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme else {
            return false
        }

        if scheme.caseInsensitiveCompare("http") == .orderedSame ||
            scheme.caseInsensitiveCompare("https") == .orderedSame {
            if let _ = URLProtocol.property(forKey: CustomURLProtocolHandledKey, in: request) {
                return false
            } else {
                return true
            }
        }
        return false
    }

    // 方法 2：【关键方法】可以在此对 request 进行处理，比如修改地址、提取请求信息、设置请求头等
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // 方法 3：【关键方法】在这里设置网络代理，重新创建一个对象将处理过的 request 转发出去。这里对应的回调方法对应 <NSURLProtocolClient> 协议方法
    // 可以在 - startLoading 中使用任何方法来对协议对象持有的 request 进行转发，包括 NSURLSession、 NSURLConnection 甚至使用 AFNetworking 等网络库，只要能在回调方法中把数据传回 client，帮助其正确渲染就可以
    override func startLoading() {
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let task = session!.dataTask(with: request)
        task.resume()
    }

    // 方法 4：主要判断两个 request 是否相同，如果相同的话可以使用缓存数据，通常只需要调用父类的实现。
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }

    // 方法 5：处理结束后停止相应请求，清空 connection 或 session
    override func stopLoading() {
        self.session?.invalidateAndCancel()
        self.session = nil
    }
}

extension CustomURLProtocol: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
    }
}
