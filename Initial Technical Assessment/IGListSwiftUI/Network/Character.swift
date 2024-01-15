import Foundation

struct Character: Decodable, Hashable, Identifiable {
    let id: Int
    var name: String?
    let description: String?
    let image: CharacterImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case image = "thumbnail"
    }
}

struct Characters: Decodable {
    let count: Int?
    let list: [Character]

    enum CodingKeys: String, CodingKey {
        case count
        case list = "results"
    }
}

struct CharactersResponse: Decodable {
    let data: Characters?
}

struct ComicsResponse: Decodable {
    let data: ComicsData?
}

struct ComicsData: Decodable {
    let count: Int?
    let list: [Comic]

    enum CodingKeys: String, CodingKey {
        case count
        case list = "results"
    }
}

struct TextObjects: Decodable {
    var text: String
    var type: String
}

struct Comic: Decodable {
    let id: Int
    var title: String
    var images : [CharacterImage] = []
    var textObjects: [TextObjects]

    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case images
        case textObjects = "textObjects"
    }
}
