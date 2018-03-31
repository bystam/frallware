//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public class FakeNetworkClient: NetworkClient {

    private var fakeResponseByType: [String : Any] = [:]
    private var fakeErrorByType: [String : Error] = [:]

    public init() {}

    public func send<C: NetworkCall & TypedResponseCall>(_ call: C, callback: @escaping (C.ResponseBody?, Error?) -> Void) -> NetworkRunnable {
        return FakeNetworkRunnable(starter: {
            if let error = self.fakeErrorByType[String(describing: C.self)] {
                callback(nil, error)
            } else if let response = self.fakeResponseByType[String(describing: C.self)] as? C.ResponseBody {
                callback(response, nil)
            }
        })
    }

    public func send<C: NetworkCall>(_ call: C, callback: @escaping (Data?, Error?) -> Void) -> NetworkRunnable {
        return FakeNetworkRunnable(starter: {
            if let error = self.fakeErrorByType[String(describing: C.self)] {
                callback(nil, error)
            } else if let data = self.fakeResponseByType[String(describing: C.self)] as? Data {
                callback(data, nil)
            }
        })
    }


    public func onCall<C: NetworkCall>(ofType type: C.Type, respondWith data: Data) {
        fakeResponseByType[String(describing: type)] = data
    }

    public func onCall<C: NetworkCall & TypedResponseCall>(ofType type: C.Type, respondWith response: C.ResponseBody) {
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
