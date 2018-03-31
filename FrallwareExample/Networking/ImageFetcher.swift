//
//  Copyright © 2018 Frallware. All rights reserved.
//

import UIKit
import Frallware

struct FetchImageCall: TypedResponseNetworkCall {

    let method: HTTPMethod = .get
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func decodeResponse(from data: Data) throws -> UIImage? {
        return UIImage(data: data)
    }
}
