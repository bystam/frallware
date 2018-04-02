//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public class StandardNetworkClient: NetworkClient {

    public struct Options {
        public var logURL: Bool = false

        public init() {}
    }

    private let options: Options
    private let session: URLSession

    public init(options: Options, session: URLSession = .shared) {
        self.options = options
        self.session = session
    }

    public func send<C: NetworkCall>(_ call: C, callback: @escaping (C.ResponseBody?, Error?) -> Void) -> NetworkRunnable {
        let request = self.request(from: call)

        if options.logURL {
            print("\(request.httpMethod!)\t\t\(request.url!)")
        }

        return session.dataTask(with: request) { data, response, error in
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
