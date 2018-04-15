//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public class FakeNetworkClient: NetworkClient {

    private var fakeResponseByType: [String : Any] = [:]
    private var fakeErrorByType: [String : Error] = [:]

    public init() {}

    public func send<C>(_ call: C, callback: @escaping (Result<NetworkResponse<C.ResponseBody>>) -> Void) -> NetworkRunnable where C : NetworkCall {
        return FakeNetworkRunnable(starter: {
            if let error = self.fakeErrorByType[String(describing: C.self)] {
                callback(.failure(error))
            } else if let response = self.fakeResponseByType[String(describing: C.self)] as? NetworkResponse<C.ResponseBody> {
                callback(.success(response))
            }
        })
    }

    public func onCall<C: NetworkCall>(ofType type: C.Type, respondWith response: NetworkResponse<C.ResponseBody>) {
        fakeResponseByType[String(describing: type)] = response
    }

    public func onCall<C: NetworkCall>(ofType type: C.Type, failWith error: Error) {
        fakeErrorByType[String(describing: type)] = error
    }
}

private class FakeNetworkRunnable: NetworkRunnable {

    private let starter: () -> Void

    init(starter: @escaping () -> Void) {
        self.starter = starter
    }

    func start() {
        starter()
    }

    func cancel() {
    }
}
