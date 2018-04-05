//
//  Copyright © 2018 Frallware. All rights reserved.
//

import UIKit
import Frallware

class ViewController: UIViewController {

    private let client = StandardNetworkClient(options: .init())

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tap)

        loadRandomFox()
    }

    @objc private func didTap() {
        loadRandomFox()
    }

    private func loadRandomFox() {
        let call = RandomFoxCall()
        client.request(call)
            .onResponse { self.loadImage(at: $0.image) }
            .onError(printError)
            .start()
    }

    private func loadImage(at url: URL) {
        let call = FetchImageCall(url: url)
        client.request(call)
            .onResponse(setImage)
            .onError(printError)
            .start()
    }

    private func setImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }

    private func printError(_ error: Error) {
        print(error)
    }
}
