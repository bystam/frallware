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
        let request = _request(from: call)
        let task = session.dataTask(with: request, completionHandler: _bodyResponse(from: call, callback: callback))
        task.resume()
    }

    public func send<C: NetworkCall & JSONRequestCall>(_ call: C, callback: @escaping (Error?) -> Void) {
        do {
            let request = try _bodyRequest(from: call)
            let task = session.dataTask(with: request, completionHandler: _voidResponse(from: callback))
            task.resume()
        } catch let error {
            callback(error)
        }
    }

    public func send<C: NetworkCall & JSONRequestCall & JSONResponseCall>(_ call: C, callback: @escaping (Result<C.ResponseBody>) -> Void) {
        do {
            let request = try _bodyRequest(from: call)
            let task = session.dataTask(with: request, completionHandler: _bodyResponse(from: call, callback: callback))
            task.resume()
        } catch let error {
            callback(.error(error))
        }
    }

    private func _bodyRequest<C: NetworkCall & JSONRequestCall>(from call: C) throws -> URLRequest {
        var request = _request(from: call)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try call.bodyEncoder.encode(call.body)
        return request
    }

    private func _request<C: NetworkCall>(from call: C) -> URLRequest {
        var request = URLRequest(url: call.url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 20.0)
        request.httpMethod = call.method.rawValue
        call.headers.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }
        return request
    }

    private func _voidResponse(from callback: @escaping (Error?) -> Void) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, response, error in
            callback(error)
        }
    }

    private func _bodyResponse<C: NetworkCall & JSONResponseCall>(from call: C, callback: @escaping (Result<C.ResponseBody>) -> Void) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, response, error in
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
}
