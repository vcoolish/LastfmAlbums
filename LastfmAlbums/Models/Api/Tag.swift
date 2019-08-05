import Foundation

class Tag : Codable {
    
    var name : String!
    var url: String!
    
    static func getTagsString(_ tags: [Tag]) -> String? {
        
        if tags.isEmpty {
            return nil
        } else if tags.count == 1 {
            return tags[0].name
        }
        let tagNames: [String] = tags.map { $0.name }
        return tagNames.joined(separator: ", ")
    }
}
