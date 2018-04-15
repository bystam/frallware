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
            .onSuccess { self.loadImage(at: $0.body.image) }
            .onFailure(printError)
            .start()
    }

    private func loadImage(at url: URL) {
        let call = FetchImageCall(url: url)
        client.request(call)
            .onSuccess { self.setImage($0.body) }
            .onFailure(printError)
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
