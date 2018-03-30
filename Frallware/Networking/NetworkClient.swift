//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

private struct MissingBodyError: Error {

    let url: URL?

    var localizedDescription: String {
        guard let url = url else {
            return "Response body was empty"
        }
        return "Response body was empty for URL: \(url)"
    }
}


public class NetworkTask<C: NetworkCall> {

    public let call: C

    fileprivate var task: URLSessionTask?
    private var responseHandler: ((Result<Data?>) -> Void)?

    fileprivate init(call: C) {
        self.call = call
    }

    fileprivate func success(_ data: Data?) {
        responseHandler?(.success(data))
    }

    fileprivate func consume(error: Error) {
        responseHandler?(.error(error))
    }


    public func start() -> NetworkTask<C> {
        task?.resume()
        return self
    }

    public func cancel() -> NetworkTask<C> {
        task?.cancel()
        return self
    }

    public func onComplete(_ handler: @escaping (Result<Void>) -> Void) -> NetworkTask<C> {
        self.responseHandler = { result in
            let voidResult = result.map { _ in () }
            handler(voidResult)
        }
        return self
    }

    public func onData(_ handler: @escaping (Result<Data>) -> Void) -> NetworkTask<C> {
        self.responseHandler = { result in
            let dataResult = result.map { data -> Data in
                guard let data = data else {
                    throw MissingBodyError(url: self.task?.currentRequest?.url)
                }
                return data
            }
            handler(dataResult)
        }
        return self
    }
}


public class NetworkClient {

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

    public func request<C: NetworkCall>(_ call: C) -> NetworkTask<C> {
        var request = URLRequest(url: call.url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 20.0)

        request.httpMethod = call.method.rawValue
        call.headers.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }

        if let bodyCall = call as? NetworkBodyCall {
            request.setValue(bodyCall.bodyMimeType, forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyCall.bodyData
        }

        let networkTask = NetworkTask<C>(call: call)
        networkTask.task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                networkTask.consume(error: error)
            } else {
                networkTask.success(data)
            }
        }
        return networkTask
    }
}
