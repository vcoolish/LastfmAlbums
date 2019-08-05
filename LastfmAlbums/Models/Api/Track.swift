class Track : Codable {
    
    var rank: Int!
    var name: String!
    var duration: String!
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        duration = secondsToInterval(Int(try container.decode(String.self, forKey: .duration)) ?? 0)
        
        let rankContainer = try container.nestedContainer(keyedBy: RankCodingKeys.self, forKey: .rank)
        self.rank = Int(try rankContainer.decode(String.self, forKey: .rank))
    }
    
    private enum CodingKeys: String, CodingKey {
        case rank = "@attr"
        case name
        case duration
    }
    
    private enum RankCodingKeys: String, CodingKey {
        case rank
    }
    
    private func secondsToInterval(_ seconds : Int) -> String {
        let hours = seconds / 3600
        let secondsTime = (seconds % 3600) % 60
        let secondsFormattedTime = secondsTime < 10 ? "0\(secondsTime)" : "\(secondsTime)"
        let timeString = "\((seconds % 3600) / 60):\(secondsFormattedTime)"
        
        return hours < 1 ?  timeString : "\(hours):\(timeString)"
    }
}
