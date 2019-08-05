import Foundation

struct Pagination {
    let startIndex, page, total : Int
}

extension Pagination : Hashable, Equatable {
    
    static func ==(lhs:Pagination, rhs:Pagination) -> Bool {
        return lhs.startIndex == rhs.startIndex && lhs.page == rhs.page && rhs.total == lhs.total
    }
    
    var hashValue: Int {
        return total.hashValue ^ page.hashValue
    }
}

struct PaginatedArtists : Decodable {
    var total: Int!
    var page: Int!
    var limit: Int!
    var startIndex : Int!
    var artists: [Artist]!
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.total = Int(try container.decode(String.self, forKey: .total))
        self.limit = Int(try container.decode(String.self, forKey: .limit))
        self.startIndex = Int(try container.decode(String.self, forKey: .startIndex))
        
        let pageContainer = try container.nestedContainer(keyedBy: PageCodingKeys.self, forKey: .page)
        self.page = Int(try pageContainer.decode(String.self, forKey: .startPage))
        
        let artistContainer = try container.nestedContainer(keyedBy: ArtistCodingKeys.self, forKey: .artists)
        self.artists = try artistContainer.decode([Artist].self, forKey: .artist)
    }
    
    private enum CodingKeys: String, CodingKey {
        case total = "opensearch:totalResults"
        case page = "opensearch:Query"
        case limit = "opensearch:itemsPerPage"
        case startIndex = "opensearch:startIndex"
        case artists = "artistmatches"
    }
    
    private enum ArtistCodingKeys: CodingKey {
        case artist
    }
    
    private enum PageCodingKeys: CodingKey {
        case startPage
    }
}
