//
//  Response+Argo.swift
//  Pods
//
//  Created by Sam Watts on 23/01/2016.
//
//
import Foundation
import Moya
import Argo

/// Extension on Moya response to map to an object(s) decodable with Argo
public extension Moya.Response {

    func mapError<T: Argo.Decodable>() throws -> T where T == T.DecodedType {

        let JSON = try self.mapJSON() as? [String: AnyObject] ?? [:]

        let result = JSON["result"] as? String

        let decrypt = QUEncryption.decrypt(withText: result) ?? ""

        let decryptJSON = decrypt.toJSON() ?? [:]

        if AppDelegate.enabledLog {
            print("请求失败 ========> \(decryptJSON)")
        }

        // 我们还要对自定义的错误处理
        if decryptJSON["code"] as? String == String(GashaponmachinesError.mallNotEnoughBalance.rawValue) {
            throw GashaponmachinesError.mallNotEnoughBalance
        } else if decryptJSON["code"] as? String == String(GashaponmachinesError.mallProductNotEnough.rawValue) {
            throw GashaponmachinesError.mallProductNotEnough
        }

        throw ErrorEnvelope(code: decryptJSON["code"] as? String ?? "", msg: decryptJSON["msg"] as? String ?? "")
    }

    /**
     Maps Moya response to decodable type

     - parameter rootKey: Optional root key of JSON to begin mapping

     - throws: Throws errors from either mapping to JSON, or Argo decoding

     - returns: returns a decoded object
     */
    func mapObject<T: Argo.Decodable>(rootKey: String? = nil) throws -> T where T == T.DecodedType {

        do {
            // map to JSON (even if it's wrapped it's still a dict)
            let JSON = try self.mapJSON() as? [String: AnyObject] ?? [:]

            let result = JSON["result"] as? String

            let decrypt = QUEncryption.decrypt(withText: result) ?? ""

            let decryptJSON = decrypt.toJSON() ?? [:]

            // 上传HTTP响应日志
            LogService.shared.uploadHTTPResponseLog(response: self, result: decryptJSON)

            if AppDelegate.enabledLog {
                print("请求成功 ========> \(self.request?.url?.absoluteString ?? ""), ", decryptJSON)
            }

            let decodedObject: Decoded<T>
            if let rootKey = rootKey {
                decodedObject = decode(decryptJSON, rootKey: rootKey)
            } else {
                decodedObject = decode(decryptJSON)
            }

            // return decoded value, or throw decoding error
            return try decodedValue(decoded: decodedObject, origin: decryptJSON)

        } catch {

            guard let request = self.request else { throw error }

            if AppDelegate.enabledLog {
                QLog.debug("==================== REQUEST URL ====================")
                QLog.debug(request.url?.absoluteString ?? "")
                QLog.debug("==================== REQUEST HEADER FIELDS ====================")
                QLog.debug(request.allHTTPHeaderFields?.debugDescription ?? "")
                QLog.debug("==================== REQUEST HTTP BODY ====================")
                QLog.debug(String(data: request.httpBody ?? Data(), encoding: String.Encoding.utf8) ?? "")
                QLog.debug("==================== ERROR MESSAGE ====================")
                QLog.debug(self.response?.allHeaderFields.debugDescription ?? "")
                QLog.debug("==================== x-ca-error-message ====================")
                QLog.debug(self.response?.allHeaderFields["x-ca-error-message"].debugDescription ?? "")
                QLog.debug("==================== x-ca-debug-info ====================")
                QLog.debug(self.response?.allHeaderFields["x-ca-debug-info"].debugDescription ?? "")
            }

            throw error
        }
    }

    /// Convenience method for mapping an object with a root key
    func mapObjectWithRootKey<T: Argo.Decodable>(rootKey: String) throws -> T where T == T.DecodedType {
        return try mapObject(rootKey: rootKey)
    }

    /**
     Maps Moya response to an array of decodable type

     - parameter rootKey: Optional root key of JSON to begin mapping

     - throws: Throws errors from either mapping to JSON, or Argo decoding

     - returns: returns an array of decoded object
     */
    func mapArray<T: Argo.Decodable>(rootKey: String? = nil) throws -> [T] where T == T.DecodedType {

        do {
            // map to JSON
            let JSON = try self.mapJSON()

            // decode with Argo
            let decodedArray: Decoded<[T]>
            if let rootKey = rootKey {
                // we have a root key, so we're dealing with a dict
                let dict = JSON as? [String: AnyObject] ?? [:]
                decodedArray = decode(dict, rootKey: rootKey)
                return try decodedValue(decoded: decodedArray, origin: dict)
            } else {
                // no root key, it's an array
                guard let array = JSON as? [AnyObject] else {
                    throw DecodeError.typeMismatch(expected: "\(T.DecodedType.self)", actual: "\(type(of: JSON))")
                }
                decodedArray = decode(array)
                return try decodedValue(decoded: decodedArray, origin: ["data": array])
            }

            // return array of decoded objects, or throw decoding error
        } catch {

            throw error
        }
    }

    /// Convenience method for mapping an array with a root key
    func mapArrayWithRootKey<T: Argo.Decodable>(rootKey: String) throws -> [T] where T == T.DecodedType {

        return try mapArray(rootKey: rootKey)
    }

    /**
     Helper function which takes a decoded value and returns a value, or throws an error

     - parameter decoded: result of Argo decoding

     - throws: throws Argo error from decoding process

     - returns: returns the decoded value if decoding was successful
     */
    //https://gitee.com/ssdev/dashboard/wikis/ssdev%2FNiuDanJi/%E6%95%B0%E6%8D%AE%E8%BF%94%E5%9B%9E?parent=%E7%A7%BB%E5%8A%A8%E5%AE%A2%E6%88%B7%E7%AB%AF%2FAPI%E5%8F%82%E8%80%83
    private func decodedValue<T>(decoded: Decoded<T>, origin: [String: Any]) throws -> T {
        if let code = origin["code"] as? String, let msg = origin["msg"] as? String {
            switch decoded {
            case .success(let value):
            	// success (data 里面有数据，且正确解析)
                return value
            case .failure(let error):
                if code == "1" {
                    // failure (data 里面没有数据，但是 code == 1 || code == 0) => `http请求成功，但具体操作失败/成功`
                    throw ErrorEnvelope(code: code, msg: msg)
                } else {
                    // data 里有数据，但是解析失败
                    QLog.error("Argo 解析错误: \(error.description)")
                    throw error
                }
            }
        }
        throw GashaponmachinesError.unknownError
    }
}
