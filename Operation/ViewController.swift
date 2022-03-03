//
//  ViewController.swift
//  Operation
//
//  Created by lian on 2022/3/3.
//

import Cocoa
import Combine

class ViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    
    let queue: OperationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let operation = ImageOperation(string: "https://henglink-dynamic-1257167958.cos.ap-shanghai.myqcloud.com/1617074675626/36368d544a2599bc1a01491bdb3eb0d5.jpeg") { result in
            switch result {
            case .success(let image):
                self.imageView.image = image
            case .failure(let error):
                print(error)
            }
        }
        
        queue.addOperation(operation!)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

class ImageOperation: AsyncOperation {
    
    typealias ImageOperationCompletion = (Result<NSImage?, Error>) -> Void
    
    var image: NSImage?
    
    private let url: URL
    
    private let completion: ImageOperationCompletion?
    
    var cancelable: AnyCancellable?
    
    init(url: URL, completion: ImageOperationCompletion? = nil) {
        self.url = url
        self.completion = completion
    }
    
    convenience init?(string: String, completion: ImageOperationCompletion? = nil) {
        guard let url = URL(string: string) else { return nil }
        self.init(url: url, completion: completion)
    }
    
    override func main() {
        cancelable = URLSession.shared.dataTaskPublisher(for: url).receive(on: DispatchQueue.main, options: nil).sink { complete in
            switch complete {
            case .finished:
                self.completion?(.success(self.image))
            case .failure(let error):
                self.completion?(.failure(error))
            }
            self.state = .finished
        } receiveValue: { (data, response) in
            let image = NSImage(data: data)
            self.image = image
        }
    }
}
