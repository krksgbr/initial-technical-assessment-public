import UIKit

class ImageLoader {
    typealias Completion = (Result<UIImage, ImageLoader.LoadError>) -> Void
    private var completionsByURL: [URL: [Completion]] = [:]
    private let cache = NSCache<NSURL, UIImage>()

    init() {
        cache.totalCostLimit = 5 * 1024 * 1024
    }

    public enum LoadError: Error {
        case corruptImage
        case networkError(Error)
    }

    public func fetch(_ url: URL, completion: @escaping (Result<UIImage, ImageLoader.LoadError>) -> Void) {
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            return completion(.success(cached))
        }

        if var completions = completionsByURL[url] {
            completions.append(completion)
            completionsByURL[url] = completions
        } else {
            completionsByURL[url] = [completion]
            URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, _, error in
                let result: Result<UIImage, LoadError>

                if let error = error {
                    result = .failure(.networkError(error))
                } else if let data = data, let image = UIImage(data: data) {
                    self?.cache.setObject(image, forKey: key, cost: data.count)
                    result = .success(image)
                } else {
                    result = .failure(.corruptImage)
                }

                if let completions = self?.completionsByURL[url] {
                    DispatchQueue.main.async {
                        completions.forEach { $0(result) }
                        self?.completionsByURL.removeValue(forKey: url)
                    }
                }
            }.resume()
        }
    }
}
