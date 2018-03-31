//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public class StandardNetworkClient: NetworkClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send<C: NetworkCall>(_ call: C, callback: @escaping (C.ResponseBody?, Error?) -> Void) -> NetworkRunnable {
        return session.dataTask(with: request(from: call)) { data, response, error in
            do {
                let data = data ?? Data()
                let response = try call.decodeResponse(from: data)
                callback(response, nil)
            } catch let error {
                callback(nil, error)
            }
        }
    }

    private func request<C: NetworkCall>(from call: C) -> URLRequest {
        var request = URLRequest(url: call.url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 20.0)

        request.httpMethod = call.method.rawValue
        call.httpHeaders.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }

        request.setValue(call.bodyMimeType, forHTTPHeaderField: "Content-Type")
        request.httpBody = call.encode(body: call.body)

        return request
    }
}

extension URLSessionTask: NetworkRunnable {

    public func start() {
        resume()
    }
}
