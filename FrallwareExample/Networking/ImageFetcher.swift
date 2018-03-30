//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation
import Frallware

struct FetchImageCall: NetworkCall {

    let method: HTTPMethod = .get
    let url: URL

    init(url: URL) {
        self.url = url
    }
}
