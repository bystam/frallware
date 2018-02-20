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
    public static let delete = HTTPMethod("DELETE")
}

public class HTTPClient {

    private static let urlSession = URLSession(configuration: .default)

    private let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func voidRequest(_ method: HTTPMethod, path: String, body: Data?) -> Task<Void> {
        guard let url = URL(string: baseURL.absoluteString.appending(path)) else {
            fatalError()
        }
        return request(method, url: url, body: body, task: VoidTask())
    }

    public func voidRequest(_ method: HTTPMethod, url: URL, body: Data?) -> Task<Void> {
        return request(method, url: url, body: body, task: VoidTask())
    }

    public func dataRequest(_ method: HTTPMethod, path: String, body: Data?) -> Task<Data> {
        guard let url = URL(string: baseURL.absoluteString.appending(path)) else {
            fatalError()
        }
        return request(method, url: url, body: body, task: DataTask())
    }

    public func dataRequest(_ method: HTTPMethod, url: URL, body: Data?) -> Task<Data> {
        return request(method, url: url, body: body, task: DataTask())
    }

    private func request<T>(_ method: HTTPMethod, url: URL, body: Data?, task: Task<T>) -> Task<T> {
        var request = URLRequest(url: url)
        request.httpMethod = method.stringValue

        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = body
        }

        task.task = HTTPClient.urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                task.consume(error: error)
            } else if let data = data {
                task.consume(data: data)
            }
        }
        return task
    }
}

public extension HTTPClient {

    public class Task<T> {

        fileprivate var task: URLSessionTask!

        fileprivate var callbackQueue: DispatchQueue?
        fileprivate var successHandler: ((T) -> Void)?
        fileprivate var errorHandler: ((Error) -> Void)?

        @discardableResult
        public func start() -> Task<T> {
            task.resume()
            return self
        }

        @discardableResult
        public func cancel() -> Task<T> {
            task.cancel()
            return self
        }

        public func dispatch(on queue: DispatchQueue) -> Task<T> {
            callbackQueue = queue
            return self
        }

        public func onSuccess(handler: @escaping (T) -> Void) -> Task<T> {
            successHandler = handler
            return self
        }

        public func onError(handler: @escaping (Error) -> Void) -> Task<T> {
            errorHandler = handler
            return self
        }

        fileprivate func consume(data: Data) {
            fatalError("Override in subclasses")
        }

        fileprivate func finish(with value: T) {
            if let queue = callbackQueue {
                queue.async {
                    self.successHandler?(value)
                }
            } else {
                successHandler?(value)
            }
        }

        fileprivate func consume(error: Error) {
            if let queue = callbackQueue {
                queue.async {
                    self.errorHandler?(error)
                }
            } else {
                errorHandler?(error)
            }
        }
    }

    fileprivate class VoidTask: Task<Void> {
        override func consume(data: Data) {
            finish(with: ())
        }
    }

    fileprivate class DataTask: Task<Data> {
        override func consume(data: Data) {
            finish(with: data)
        }
    }

    fileprivate class DecodableTask<U: Decodable>: Task<U> {

        private let decoder: JSONDecoder

        init(decoder: JSONDecoder) {
            self.decoder = decoder
        }

        override func consume(data: Data) {
            do {
                let value = try decoder.decode(U.self, from: data)
                finish(with: value)
            } catch let error {
                consume(error: error)
            }
        }
    }
}

public extension HTTPClient.Task where T == Data {

    public func map<U: Decodable>(to type: U.Type, with decoder: JSONDecoder = JSONDecoder()) -> HTTPClient.Task<U> {
        let task = HTTPClient.DecodableTask<U>(decoder: decoder)
        task.task = self.task
        task.errorHandler = self.errorHandler
        task.callbackQueue = self.callbackQueue
        self.successHandler = { data in
            task.consume(data: data)
        }
        return task
    }
}

