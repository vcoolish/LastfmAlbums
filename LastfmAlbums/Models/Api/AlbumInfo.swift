import Alamofire

class AlbumInfo : Decodable {
    
    fileprivate var tags : [Tag]?
    var tracks : [Track]!
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let tagsContainer = try container.nestedContainer(keyedBy: TagsCodingKeys.self, forKey: .tags)
        self.tags = try tagsContainer.decode([Tag].self, forKey: .tag)
        
        let tracksContainer = try container.nestedContainer(keyedBy: TracksCodingKeys.self, forKey: .tracks)
        self.tracks = try tracksContainer.decode([Track].self, forKey: .track)
    }
    
    private enum CodingKeys: String, CodingKey {
        case tags = "tags"
        case tracks = "tracks"
    }
    
    private enum TagsCodingKeys: String, CodingKey {
        case tag = "tag"
    }
    
    private enum TracksCodingKeys: String, CodingKey {
        case track = "track"
    }
    
    func getTagsString() -> String? {
        if let tags = tags {
            return Tag.getTagsString(Array(tags.prefix(3)))
        }
        return nil
    }
}
