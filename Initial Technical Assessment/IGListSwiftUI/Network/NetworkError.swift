import Foundation

enum NetworkError: Error, LocalizedError {
    case badURL, badJSON, serverError
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL."
        case .badJSON:
            return "Can't load data."
        case .serverError:
            return "Server not responding."
        }
    }
}
