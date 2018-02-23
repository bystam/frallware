//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public struct HTTPMethod {
    public let stringValue: String

    public init(_ stringValue: String) {
        self.stringValue = stringValue
    }
}

public extension HTTPMethod {
    public static let get = HTTPMethod("GET")
    public static let post = HTTPMethod("POST")
    public static let put = HTTPMethod("PUT")
    public static let patch = HTTPMethod("PATCH")
    public static let delete = HTTPMethod("DELETE")
}


public protocol HTTPRequestMiddleware {
    func prepare(request: inout URLRequest)
}

public enum HTTPResponseMiddlewareResult {
    case data(Data)
    case error(Error)
}

public protocol HTTPResponseMiddleware {
    func process(data: Data) -> HTTPResponseMiddlewareResult
}


public class HTTPClient {

    public enum ClientError: Error {
        case malformedPath
        case missingResponseBody
    }

    private static let urlSession = URLSession(configuration: .default)

    private let baseURL: URL
    private let requestMiddleware: HTTPRequestMiddleware?
    private let responseMiddleware: HTTPResponseMiddleware?

    public init(baseURL: URL, requestMiddleware: HTTPRequestMiddleware? = nil, responseMiddleware: HTTPResponseMiddleware? = nil) {
        self.baseURL = baseURL
        self.requestMiddleware = requestMiddleware
        self.responseMiddleware = responseMiddleware
    }

    public func voidRequest(_ method: HTTPMethod, path: String, body: Data?) -> Task<Void> {
        guard let url = URL(string: baseURL.absoluteString.appending(path)) else {
            return task(with: ClientError.malformedPath)
        }
        return request(method, url: url, body: body, type: Void.self)
    }

    public func voidRequest(_ method: HTTPMethod, url: URL, body: Data?) -> Task<Void> {
        return request(method, url: url, body: body, type: Void.self)
    }

    public func dataRequest(_ method: HTTPMethod, path: String, body: Data?) -> Task<Data> {
        guard let url = URL(string: baseURL.absoluteString.appending(path)) else {
            return task(with: ClientError.malformedPath)
        }
        return request(method, url: url, body: body, type: Data.self)
    }

    public func dataRequest(_ method: HTTPMethod, url: URL, body: Data?) -> Task<Data> {
        return request(method, url: url, body: body, type: Data.self)
    }

    private func request<T>(_ method: HTTPMethod, url: URL, body: Data?, type: T.Type) -> Task<T> {
        var request = URLRequest(url: url)
        request.httpMethod = method.stringValue

        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = body
        }

        requestMiddleware?.prepare(request: &request)

        let task = Task<T>()
        task.task = HTTPClient.urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                task.consume(error: error)
                return
            }

            let result = data.map {
                self.responseMiddleware?.process(data: $0) ?? .data($0)
            }

            switch result {
            case .error(let error)?:
                task.consume(error: error)

            case .data(let data)?:
                if let task = task as? Task<Data> {
                    task.consume(value: data)
                } else {
                    fallthrough
                }

            case nil:
                if let task = task as? Task<Void> {
                    task.consume(value: ())
                }
            }
        }
        return task
    }

    private func task<T>(with error: Error) -> Task<T> {
        let task = Task<T>()
        task.error = error
        return task
    }
}

public extension HTTPClient {

    public class Task<T> {

        fileprivate var task: URLSessionTask?

        fileprivate var callbackQueue: DispatchQueue?
        fileprivate var successHandler: ((T) -> Void)?
        fileprivate var errorHandler: ((Error) -> Void)?

        fileprivate var consumeHandlers: [(T) -> Void] = []
        fileprivate var result: T?
        fileprivate var error: Error?

        fileprivate let lock = NSLock()

        @discardableResult
        public func start() -> Task<T> {
            lock.lock()
            defer { lock.unlock() }

            task?.resume()
            return self
        }

        @discardableResult
        public func cancel() -> Task<T> {
            lock.lock()
            defer { lock.unlock() }

            task?.cancel()
            return self
        }

        public func complete(on queue: DispatchQueue) -> Task<T> {
            lock.lock()
            defer { lock.unlock() }

            callbackQueue = queue
            return self
        }

        public func onSuccess(handler: @escaping (T) -> Void) -> Task<T> {
            lock.lock()
            defer { lock.unlock() }

            successHandler = handler

            if let result = result {
                consume(value: result)
            }

            return self
        }

        public func onError(handler: @escaping (Error) -> Void) -> Task<T> {
            lock.lock()
            defer { lock.unlock() }

            errorHandler = handler

            if let error = error {
                consume(error: error)
            }

            return self
        }

        fileprivate func consume(value: T) {
            lock.lock()
            defer { lock.unlock() }

            self.result = value
            consumeHandlers.forEach { $0(value) }

            if let queue = callbackQueue {
                queue.async {
                    self.successHandler?(value)
                }
            } else {
                successHandler?(value)
            }
        }

        fileprivate func consume(error: Error) {
            lock.lock()
            defer { lock.unlock() }

            self.error = error

            if let queue = callbackQueue {
                queue.async {
                    self.errorHandler?(error)
                }
            } else {
                errorHandler?(error)
            }
        }
    }
}

public extension HTTPClient.Task where T == Data {

    public func map<U: Decodable>(to type: U.Type, with decoder: JSONDecoder = JSONDecoder()) -> HTTPClient.Task<U> {
        lock.lock()
        defer { lock.unlock() }

        let task = HTTPClient.Task<U>()
        task.task = self.task
        task.callbackQueue = self.callbackQueue

        consumeHandlers.append { (data) in
            do {
                let result = try decoder.decode(U.self, from: data)
                task.consume(value: result)
            } catch let error {
                task.consume(error: error)
            }
        }

        return task
    }
}

