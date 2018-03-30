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
    private var successHandler: ((Data?) throws -> Void)?
    private var errorHandler: ((Error) -> Void)?

    fileprivate init(call: C) {
        self.call = call
    }

    fileprivate func consume(data: Data?) {
        if let error = data.flatMap({ call.errorMiddleware?.decodeError(from: $0) }) {
            errorHandler?(error)
            return
        }

        do {
            try successHandler?(data)
        } catch let error {
            errorHandler?(error)
        }
    }

    fileprivate func consume(error: Error) {
        errorHandler?(error)
    }


    @discardableResult
    public func start() -> NetworkTask<C> {
        task?.resume()
        return self
    }

    @discardableResult
    public func cancel() -> NetworkTask<C> {
        task?.cancel()
        return self
    }

    public func onComplete(_ handler: @escaping () -> Void) -> NetworkTask<C> {
        self.successHandler = { _ in
            handler()
        }
        return self
    }

    public func onData(_ handler: @escaping (Data) throws -> Void) -> NetworkTask<C> {
        self.successHandler = { [weak self] (data: Data?) in
            guard let data = data, !data.isEmpty else {
                throw MissingBodyError(url: self?.task?.currentRequest?.url)
            }
            try handler(data)
        }
        return self
    }

    public func onError(_ handler: @escaping (Error) -> Void) -> NetworkTask<C> {
        self.errorHandler = handler
        return self
    }
}


public class NetworkClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func request<C: NetworkCall>(_ call: C) -> NetworkTask<C> {
        var request = URLRequest(url: call.url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 20.0)

        request.httpMethod = call.method.rawValue
        call.httpHeaders.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }

        request.setValue(call.bodyMimeType, forHTTPHeaderField: "Content-Type")
        request.httpBody = call.bodyData

        let networkTask = NetworkTask<C>(call: call)
        networkTask.task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                networkTask.consume(error: error)
            } else {
                networkTask.consume(data: data)
            }
        }
        return networkTask
    }
}
