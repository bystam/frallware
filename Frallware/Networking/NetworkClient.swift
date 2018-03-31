//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation


public protocol NetworkRunnable {

    func start()
    func cancel()

}

public protocol NetworkClient {

    func send<C: TypedResponseNetworkCall>(_ call: C, callback: @escaping (C.ResponseBody?, Error?) -> Void) -> NetworkRunnable
    func send<C: NetworkCall>(_ call: C, callback: @escaping (Error?) -> Void) -> NetworkRunnable

}


public class NetworkTask<T> {

    var runnable: NetworkRunnable?

    private var successHandler: ((T) -> Void)?
    private var errorHandler: ((Error) -> Void)?


    // Internal

    func finish(with result: T) {
        successHandler?(result)
    }

    func fail(with error: Error) {
        errorHandler?(error)
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

    public func onResponse(_ handler: @escaping (T) -> Void) -> NetworkTask<T> {
        successHandler = handler
        return self
    }

    public func onError(_ handler: @escaping (Error) -> Void) -> NetworkTask<T> {
        self.errorHandler = handler
        return self
    }
}

public extension NetworkTask where T == Void {

    public func onSuccess(_ handler: @escaping () -> Void) -> NetworkTask<T> {
        return onResponse { _ in handler() }
    }
}


public extension NetworkClient {

    func request<C: TypedResponseNetworkCall>(_ call: C) -> NetworkTask<C.ResponseBody> {
        let networkTask = NetworkTask<C.ResponseBody>()

        networkTask.runnable = send(call) { response, error in
            if let error = error {
                networkTask.fail(with: error)
            } else if let response = response {
                networkTask.finish(with: response)
            } else {
                networkTask.fail(with: MissingBodyError(url: call.url))
            }
        }
        return networkTask
    }

    func request<C: NetworkCall>(_ call: C) -> NetworkTask<Void> {
        let networkTask = NetworkTask<Void>()

        networkTask.runnable = send(call) { error in
            if let error = error {
                networkTask.fail(with: error)
            } else {
                networkTask.finish(with: ())
            }
        }
        return networkTask
    }
}

