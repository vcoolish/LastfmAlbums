import UIKit

class Album : Decodable, Hashable, Equatable {
    
    var photoUrl : URL?
    var loadedImage : UIImage?
    var name : String?
    var mbid : String?
    var albumDetail : AlbumInfo?
    var artist : Artist!

    var hadDetail : Bool = false

    static func ==(lhs:Album, rhs:Album) -> Bool {
        if let lhs_mbid = lhs.mbid, let rhs_mbid = rhs.mbid {
            return lhs_mbid == rhs_mbid
        } else {
            return lhs.name == rhs.name && lhs.artist?.name == rhs.artist?.name
        }
    }
    
    var hashValue: Int {
        if let mbid = mbid {
            return mbid.hashValue ^ name.hashValue
        } else {
            return name.hashValue ^ (artist?.name.hashValue ?? 0)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        if name == "(null)" {
            name = nil
        }
        mbid = try? container.decode(String.self, forKey: .mbid)
        let images = try? container.decode([Image].self, forKey: .image)
        photoUrl = images?.filter { $0.size == "large" }.first?.url
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case mbid
        case image
    }
}
