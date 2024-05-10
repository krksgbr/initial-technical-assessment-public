import UIKit

enum SizeImage: String {
    case standard = "standard_fantastic" // 250x250px
    case landscape = "landscape_incredible" // 464x261px
    case portrait = "portrait_uncanny" // 300x450px
}

struct CharacterImage: Decodable, Hashable {
    let path: String
    let format: String

    enum CodingKeys: String, CodingKey {
        case path
        case format = "extension"
    }

    func imageURL(size: SizeImage) -> URL? {
        let httpsPath = path.replacingOccurrences(of: "http", with: "https")
        return URL(string: "\(httpsPath)/\(size.rawValue).\(format)")
    }
}
