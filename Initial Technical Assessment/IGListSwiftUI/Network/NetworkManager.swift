import CryptoKit
import Foundation

import UIKit

private class Constants {
    enum API {
        static let URL = "https://gateway.marvel.com/v1/public/"
        static let apiPublicKey = ""
        static let apiPrivateKey = ""
    }
}

class NetworkManager {
    static let shared = NetworkManager()

    func buildParams(offset: Int, limit: Int, orderBy: String) -> [String: String] {
        let timestamp = String(Date().getTimeIntervalSince1970())
        let hash = String(timestamp + Constants.API.apiPrivateKey + Constants.API.apiPublicKey).md5()
        return [
            "apikey": Constants.API.apiPublicKey,
            "ts": timestamp,
            "hash": hash,
            "offset": String(offset),
            "limit": String(limit),
            "orderBy": orderBy
        ]
    }

    func fetchCharacters(offset: Int, limit: Int) async throws -> [Character] {
        let parameters = self.buildParams(offset: offset, limit: limit, orderBy: "name")
        let urlString = "\(Constants.API.URL)characters"

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

    func fetchComics(with id: Int, offset: Int, limit: Int) async throws -> [Comic] {
        let parameters = self.buildParams(offset: offset, limit: limit, orderBy: "issueNumber")

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

    static var session = URLSession.shared
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
