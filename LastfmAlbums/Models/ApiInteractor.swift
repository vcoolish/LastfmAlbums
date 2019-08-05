import Alamofire
import CodableAlamofire

func getArtistSearch(
    query: String,
    pagination: Pagination,
    onSuccess: @escaping (PaginatedArtists) -> (),
    onError: @escaping (String) -> ()
) {
    let urlString = String(
        format: Constants.Api.ArtistSearch,
        query, String(Constants.Search.maxResults),
        String(pagination.page)
    )
    if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        Alamofire
            .request(url)
            .responseDecodableObject(
            keyPath: "results",
            decoder: JSONDecoder()
        ) { (response: DataResponse<PaginatedArtists>) in
            let (success, error) = handleResponse(response)
            if let error = error {
                onError(error)
            } else {
                if let data = success {
                    onSuccess(data)
                }
            }
        }
    } else {
        onError(Constants.Error.wrongRequest)
    }
}

func getTopAlbums(
    artist: Artist,
    onSuccess: @escaping ([Album]) -> (),
    onError: @escaping (String) -> ()
    ) {
    if let id = artist.mbid {
        let url = String(format: Constants.Api.ArtistAlbums, id)
        
        Alamofire
            .request(url)
            .responseDecodableObject(
                keyPath: "topalbums.album",
                decoder: JSONDecoder()
            ) { (response: DataResponse<[Album]>) in
                
            let (success, error) = handleResponse(response)
            if let error = error {
                onError(error)
            } else {
                if let data = success {
                    for album in data {
                        album.artist = artist
                    }
                    onSuccess(data)
                }
            }
        }
    }
}

func getAlbumInfo(
    album: Album,
    onSuccess: @escaping (AlbumInfo) -> (),
    onError: @escaping (String) -> ()
) {
    var url : String?
    if let mbid = album.mbid {
        url = String(format: Constants.Api.AlbumInfoId, mbid)
    } else if let albumName = album.name, let artistName = album.artist?.name {
        url = String(format: Constants.Api.AlbumInfoNameArtist, albumName, artistName)
//            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    if let validUrl = url {
        Alamofire.request(validUrl).responseDecodableObject(
            keyPath: "album", decoder: JSONDecoder()
        ) { (response: DataResponse<AlbumInfo>) in
            let (success, error) = handleResponse(response)
            if let error = error {
                onError(error)
            } else {
                onSuccess(success!)
            }
        }
    } else {
        onError(Constants.Error.wrongRequest)
    }
}

func getArtistInfo(
    artistId: String,
    onSuccess: @escaping (ArtistInfo) -> (),
    onError: @escaping (String) -> ()
) {
    let URL = String(format: Constants.Api.ArtistInfo, artistId)
    
    Alamofire
        .request(URL)
        .responseDecodableObject(
            keyPath: "artist",
            decoder: JSONDecoder()
        ) { (response: DataResponse<ArtistInfo>) in
        let (success, error) = handleResponse(response)
        
        if let error = error {
            onError(error)
        } else {
            onSuccess(success!)
        }
    }
}

func handleResponse<T>(_ response: DataResponse<T>) -> (T?,String?) {
    
    let status = response.response?.statusCode
    switch status ?? -1 {
    case 403:
        return (nil,Constants.Error.authenticationError)
    case 500, 404:
        return (nil,Constants.Error.serverError)
    case 200:
        if let x : T = response.value {
            return (x,nil)
        } else {
            return (nil,Constants.Error.wrongRequest)
        }
    case -1:
        return (nil,Constants.Error.connectionError)
    default:
        if (response.error != nil) {
            return (nil,Constants.Error.connectionError)
        } else {
            return (nil,Constants.Error.serverError)
        }
    }
}
