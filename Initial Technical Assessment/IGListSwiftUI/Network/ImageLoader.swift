import UIKit

class ImageLoader {
    private var images: [URL: LoaderStatus] = [:]

    private enum LoaderStatus {
        case inProgress([(Result<UIImage, ImageLoader.LoadError>) -> Void])
        case fetched(UIImage)
    }

    public enum LoadError: Error {
        case corruptImage
        case networkError(Error)
    }

    public func fetch(_ url: URL, completion: @escaping (Result<UIImage, ImageLoader.LoadError>) -> Void) {
        if let status = images[url] {
            switch status {
            case .fetched(let image):
                completion(.success(image))
                return
            case .inProgress(var callbacks):
                callbacks.append(completion)
                images[url] = .inProgress(callbacks)
                return
            }
        }

        images[url] = .inProgress([completion])
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            let result: Result<UIImage, LoadError>

            if let error = error {
                result = .failure(.networkError(error))
            } else if let data = data, let image = UIImage(data: data) {
                result = .success(image)
            } else {
                result = .failure(.corruptImage)
            }

            DispatchQueue.main.async { [weak self] in
                self?.complete(for: url, with: result)
            }

        }.resume()
    }

    private func complete(for url: URL, with result: Result<UIImage, ImageLoader.LoadError>) {
        guard let completions = images[url] else { return }

        switch result {
        case .success(let image):
            images[url] = .fetched(image)
        case .failure:
            images.removeValue(forKey: url)
        }

        if case .inProgress(let callbacks) = completions {
            callbacks.forEach { $0(result) }
        }
    }
}
