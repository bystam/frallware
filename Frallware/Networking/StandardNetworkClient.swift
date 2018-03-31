//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public class StandardNetworkClient: NetworkClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send<C: NetworkCall & TypedResponseCall>(_ call: C, callback: @escaping (C.ResponseBody?, Error?) -> Void) -> NetworkRunnable {
        return self.send(call) { (data: Data?, error: Error?) in
            do {
                let data = data ?? Data()
                let response = try call.decodeResponse(from: data)
                callback(response, nil)
            } catch let error {
                callback(nil, error)
            }
        }
    }

    public func send<C: NetworkCall>(_ call: C, callback: @escaping (Data?, Error?) -> Void) -> NetworkRunnable {
        var request = URLRequest(url: call.url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 20.0)

        request.httpMethod = call.method.rawValue
        call.httpHeaders.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }

        request.setValue(call.bodyMimeType, forHTTPHeaderField: "Content-Type")
        request.httpBody = call.bodyData

        return session.dataTask(with: request) { data, response, error in
            if let error = error {
                callback(nil, error)
            } else if let error = data.flatMap({ call.errorMiddleware?.decodeError(from: $0) }) {
                callback(nil, error)
            } else {
                callback(data, nil)
            }
        }
    }
}

extension URLSessionTask: NetworkRunnable {

    public func start() {
        resume()
    }
}
