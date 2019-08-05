import UIKit

class AlbumDTO {
    var inMemoryImage : UIImage?
    var photoUrl : URL?
    var name : String?
    var tags : String?
    var hashString : String
    var storedAlbum : AlbumMO?
    var tracks = [TrackDTO]()
    var artist : ArtistDTO?
    var localMode = false
    
    init(album: Album, image: UIImage? = nil) {
        
        self.inMemoryImage = image
        self.photoUrl = album.photoUrl
        if let albumName = album.name, let artistName = album.artist?.name, let artistId = album.artist?.mbid {
            self.name = albumName
            self.artist = ArtistDTO(name: artistName, mbid: artistId, photoUrl: album.artist?.photoUrl, url: album.artist?.url)
        }
        self.hashString = String(album.hashValue)
        self.storedAlbum = AlbumMO.get(from: self.hashString)
        
        guard let detail = album.albumDetail else {
            assertionFailure("Couldn't fetch album detail")
            return
        }
        
        self.tags = detail.getTagsString()
        
        
        for _track in detail.tracks {
            let track = TrackDTO(number: _track.rank, title: _track.name, lengthStatic: _track.duration)
            self.tracks.append(track)
        }
    }
    
    init(albumMO: AlbumMO, image: UIImage? = nil) {
        self.inMemoryImage = image
        self.photoUrl = albumMO.photoUrl != nil ? URL(string: albumMO.photoUrl!) : nil
        self.name = albumMO.name ?? ""
        self.tags = albumMO.tags
        
        self.artist = ArtistDTO(name: albumMO.artist?.name ?? "", mbid: albumMO.artist?.mbid ?? "", photoUrl: albumMO.artist?.getPhotoUrl(), url: albumMO.artist?.getUrl())
        
        if let hash = albumMO.stringHash {
            self.hashString = hash
        } else {
            self.hashString = String(UInt32(name.hashValue) ^ (arc4random_uniform(UInt32(name?.count ?? 0)) + arc4random_uniform(100)))
        }
        
        self.storedAlbum = albumMO
        
        let _tracks = (albumMO.tracks as! Set<TrackMO>).sorted(by: { $0.number < $1.number })
        for _track in _tracks {
            let track = TrackDTO(number: Int(_track.number), title: _track.title, lengthStatic: _track.lengthStatic)
            self.tracks.append(track)
        }
        self.localMode = true
    }
}
