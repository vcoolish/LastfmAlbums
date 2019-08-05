import Alamofire

struct ArtistInfo : Codable {
    
    fileprivate var tags : [Tag]?
    var description : String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let tagsContainer = try container.nestedContainer(keyedBy: TagsCodingKeys.self, forKey: .tags)
        self.tags = try tagsContainer.decode([Tag].self, forKey: .tag)
        
        let summaryContainer = try container.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .description)
        self.description = try summaryContainer.decode(String.self, forKey: .summary)
        cropDescription()
    }
    
    private enum CodingKeys: String, CodingKey {
        case tags
        case description = "bio"
    }
    
    private enum TagsCodingKeys: CodingKey {
        case tag
    }
    
    private enum SummaryCodingKeys: CodingKey {
        case summary
    }
    
    func getTagsString() -> String? {
        if let tags = tags {
            return Tag.getTagsString(tags)
        }
        return nil
    }
    
    private mutating func cropDescription() {
        if let descr = description {
            let descriptionSplitHrefTag = descr.components(separatedBy: "<a href=\"")
            if descriptionSplitHrefTag.count > 1 {
                self.description = descriptionSplitHrefTag[0]
            }
        }
    }
}
