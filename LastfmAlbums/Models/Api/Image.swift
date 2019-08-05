import Foundation

struct Image: Decodable {
    var url: URL?
    var size: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case url = "#text"
        case size = "size"
    }
}
