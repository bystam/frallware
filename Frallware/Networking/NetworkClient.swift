//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public class NetworkClient {

    public enum Result<T> {
        case success(T)
        case error(Error)
    }

    public struct MissingBodyError: Error {
        let url: URL

        public var localizedDescription: String {
            return "Response body was empty for URL: \(url)"
        }
    }


    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    public func send<C: NetworkCall & JSONResponseCall>(_ call: C, callback: @escaping (Result<C.ResponseBody>) -> Void) {
        _send(call) { (data, error) in
            guard let data = data, !data.isEmpty else {
                callback(.error(error ?? MissingBodyError(url: call.url)))
                return
            }

            do {
                let responseBody = try call.bodyDecoder.decode(C.ResponseBody.self, from: data)
                callback(.success(responseBody))
            } catch let error {
                callback(.error(error))
            }
        }
    }

    public func send<C: NetworkCall>(_ call: C, callback: @escaping (Error?) -> Void) {
        _send(call) { data, error in
            callback(error)
        }
    }

    private func _send<C: NetworkCall>(_ call: C, callback: @escaping (Data?, Error?) -> Void) {
        var request = URLRequest(url: call.url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 20.0)
        request.httpMethod = call.method.rawValue
        call.headers.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }

        request.setValue(call.bodyMimeType, forHTTPHeaderField: "Content-Type")
        request.httpBody = call.bodyData

        let task = session.dataTask(with: request) { (data, response, error) in

            // TODO: error middleware

            callback(data, error)
        }
        task.resume()
    }
}

private extension NetworkCall {

    var bodyMimeType: String? {
        return nil
    }

    var bodyData: Data? {
        return nil
    }
}

private extension NetworkCall where Self: JSONRequestCall {

    var bodyMimeType: String? {
        return "application/json"
    }

    var bodyData: Data? {
        return try? bodyEncoder.encode(body)
    }
}
