//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation


public protocol NetworkRunnable {

    func start()
    func cancel()

}

public struct NetworkResponse<T> {

    public let httpStatus: Int
    public let body: T

}

public protocol NetworkClient {

    func send<C: NetworkCall>(_ call: C, callback: @escaping (Result<NetworkResponse<C.ResponseBody>>) -> Void) -> NetworkRunnable

}


public class NetworkTask<T> {

    var runnable: NetworkRunnable?

    private var resultHandlers: [(Result<T>) -> Void] = []


    // Internal

    func succeed(with value: T) {
        resultHandlers.forEach { handler in
            handler(.success(value))
        }
    }

    func fail(with error: Error) {
        resultHandlers.forEach { handler in
            handler(.error(error))
        }
    }


    // Public

    @discardableResult
    public func start() -> NetworkTask<T> {
        runnable?.start()
        return self
    }

    @discardableResult
    public func cancel() -> NetworkTask<T> {
        runnable?.cancel()
        return self
    }

    public func onResult(_ handler: @escaping (Result<T>) -> Void) -> NetworkTask<T> {
        resultHandlers.append(handler)
        return self
    }

    public func onSuccess(_ handler: @escaping (T) -> Void) -> NetworkTask<T> {
        resultHandlers.append { (result) in
            if case .success(let value) = result {
                handler(value)
            }
        }
        return self
    }

    public func onFailure(_ handler: @escaping (Error) -> Void) -> NetworkTask<T> {
        resultHandlers.append { (result) in
            if case .error(let error) = result {
                handler(error)
            }
        }
        return self
    }
}

public extension NetworkClient {

    func request<C: NetworkCall>(_ call: C) -> NetworkTask<NetworkResponse<C.ResponseBody>> {
        let networkTask = NetworkTask<NetworkResponse<C.ResponseBody>>()

        networkTask.runnable = send(call) { result in
            switch result {
            case .success(let response):
                networkTask.succeed(with: response)
            case .error(let error):
                networkTask.fail(with: error)
            }
        }
        return networkTask
    }
}
