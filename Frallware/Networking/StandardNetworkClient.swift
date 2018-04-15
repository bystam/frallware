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

    public func send<C>(_ call: C, callback: @escaping (Result<NetworkResponse<C.ResponseBody>>) -> Void) -> NetworkRunnable where C : NetworkCall {
        let request = self.request(from: call)

        if options.logURL {
            print("\(request.httpMethod!)\t\t\(request.url!)")
        }

        return session.dataTask(with: request) { data, response, error in
            do {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let data = data ?? Data()

                if let error = call.decodeError(from: data) {
                    callback(.failure(error))
                } else {
                    let body = try call.decodeBody(from: data)
                    let response = NetworkResponse(httpStatus: statusCode, body: body)
                    callback(.success(response))
                }

            } catch let error {
                callback(.failure(error))
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
