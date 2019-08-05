import Alamofire

class Artist : Decodable {
    
    var detail: ArtistInfo?
    var albums : [Album]?
    var requestedAlbumDetails : Dictionary<Album,Bool>?
    
    var photoUrl : URL?
    var url : URL?
    var listeners : Int?
    
    var name : String?
    var mbid : String?
    
    
    init(from artist: ArtistMO) {
        self.name = artist.name ?? ""
        self.mbid = artist.mbid ?? ""
        self.photoUrl = artist.getPhotoUrl()
        self.url = artist.getUrl()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        mbid = try container.decode(String.self, forKey: .mbid)
        url = try container.decode(URL.self, forKey: .url)
        listeners = Int(try container.decode(String.self, forKey: .listeners))
        let images = try? container.decode([Image].self, forKey: .image)
        photoUrl = images?.filter { $0.size == "large" }.first?.url
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case mbid
        case url
        case listeners
        case image
    }
}
