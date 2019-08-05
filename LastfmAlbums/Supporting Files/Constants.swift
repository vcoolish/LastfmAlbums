import Foundation

class Constants {
    struct Api {
        static let API_KEY = "0dbd6cf758cb3887b274de2d0af0c699"
        static let BASE_URL = "https://ws.audioscrobbler.com/2.0/"
        
        static let ApiUrlMethod = "\(BASE_URL)?api_key=\(API_KEY)&format=json&method="
        
        static let ArtistInfo = "\(ApiUrlMethod)artist.getinfo&mbid=%@"
        static let ArtistAlbums = "\(ApiUrlMethod)artist.getTopAlbums&mbid=%@"
        static let ArtistSearch = "\(ApiUrlMethod)artist.search&artist=%@&limit=%@&page=%@"
        static let AlbumInfoId = "\(ApiUrlMethod)album.getInfo&mbid=%@"
        static let AlbumInfoNameArtist = "\(ApiUrlMethod)album.getInfo&album=%@&artist=%@"
    }
    
    struct Error {
        static let somethingWrong = "Something went wrong"
        static let wrongRequest = "Wrong Request"
        static let connectionError = "Connection Error"
        static let serverError = "Server error"
        static let authenticationError = "Authentication Error"
        static let error = "Error"
    }
    
    struct Search {
        static let minQueryLength = 2
        static let maxResults = 12
        static let maxPageNumber = 50
        static let pageDecrement = 2
        
        static let searchInterval = 0.5
    }
    
    struct Dimensions {
        static let safeMargin = 8.0
    }
    
    struct Files {
        static let albumFile = "album_%@.jpg"
        static let albumsFolder = "albums"
    }
    
    static let defaultPagination = Pagination(startIndex: 0, page: 1, total: Search.maxResults)
}
