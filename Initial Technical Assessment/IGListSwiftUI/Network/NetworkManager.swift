import Foundation
import CryptoKit

import UIKit

private class Constants {
    struct API {
        static let URL = "https://gateway.marvel.com/v1/public/"
        static let apiPublicKey = <# apiPublicKey #>
        static let apiPrivateKey = <# apiPrivateKey #>
        static var timestamp: String {
            return String(Date().getTimeIntervalSince1970())
        }
        static var hash: String {
            return String(timestamp + apiPrivateKey + apiPublicKey).md5()
        }
        static var parametrs = ["apikey": apiPublicKey,
                                "ts": timestamp,
                                "hash": hash,
                                "limit": "50"]
    }
}

class NetworkManager {

    static let shared = NetworkManager()

    func fetchCharacters(with name: String? = nil) async throws -> [Character] {
        var parameters = Constants.API.parametrs
        let urlString = "\(Constants.API.URL)characters"

        if let name = name, !name.isEmpty {
            parameters["nameStartsWith"] = name
        } else {
            parameters.removeValue(forKey: "nameStartsWith")
        }

        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = urlComponents?.url else {
            throw NetworkError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let result = try await NetworkManager.session.data(for: request)

            guard let httpResponse = result.1 as? HTTPURLResponse else {
                throw NetworkError.serverError
            }

            if !(200..<300).contains(httpResponse.statusCode) {
                throw NetworkError.badURL
            }

            let data = result.0

            do {
                let characters = try JSONDecoder().decode(CharactersResponse.self, from: data)
                return characters.data?.list ?? []
            } catch {
                throw NetworkError.badJSON
            }
        } catch {
            return []
        }
    }

    func fetchComics(with id: String) async throws -> [Comic] {
        let parameters = Constants.API.parametrs
        let urlString = "\(Constants.API.URL)characters/\(id)/comics"

        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = urlComponents?.url else {
            throw NetworkError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let result = try await NetworkManager.session.data(for: request)

            guard let httpResponse = result.1 as? HTTPURLResponse else {
                throw NetworkError.serverError
            }

            if !(200..<300).contains(httpResponse.statusCode) {
                throw NetworkError.badURL
            }

            let data = result.0

            do {
                let characters = try JSONDecoder().decode(ComicsResponse.self, from: data)
                return characters.data?.list ?? []
            } catch {
                throw NetworkError.badJSON
            }
        } catch {
            return []
        }
        
    }

    static var session = {
        return URLSession.shared
    }()

}

extension String {
    func md5() -> String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

extension Date {
    func getTimeIntervalSince1970() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
