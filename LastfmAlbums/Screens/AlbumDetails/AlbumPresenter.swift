import UIKit
import AlamofireImage

class AlbumPresenter {
    
    var storedImage : UIImage?
    weak private var albumView: AlbumView?
    
    func attachView(view: AlbumView) {
        albumView = view
    }
    
    func detachView() {
        albumView = nil
    }
    
    func setAlbumImage(albumInfoHeader: AlbumVcHeaderView) {
        if let dto = albumView?.getAlbumDTO() {
            
            if let albumImage = dto.inMemoryImage {
                albumInfoHeader.imageView.image = albumImage
                storedImage = albumImage
            } else if let photoUrl = dto.photoUrl {
                albumInfoHeader
                    .imageView
                    .af_setImage(
                        withURL: photoUrl,
                        placeholderImage: UIImage(),
                        completion: { response in
                            if response.result.value == nil {
                                albumInfoHeader.imageView.image = UIImage(named: "AlbumMedia")!
                            } else if dto.localMode {
                                let _ = AlbumMO.saveAlbumImage(
                                    response.result.value!,
                                    identifier: dto.hashString
                                )
                            }
                        })
            } else {
                albumInfoHeader.imageView.image = UIImage(named: "AlbumMedia")
            }
            albumInfoHeader.albumArtist.text = dto.artist?.name
            albumInfoHeader.albumTags.text = dto.tags
        }
    }
    
    func saveAlbum() {
        if let dto = albumView?.getAlbumDTO() {
            if dto.storedAlbum == nil {
                if let albumMO = AlbumMO.create(from: dto, withImage: storedImage) {
                    dto.storedAlbum = albumMO
                }
            }
        }
    }
    
    func deleteAlbum() {
        if let album = albumView?.getAlbumDTO().storedAlbum {
            if AlbumMO.delete(album: album) {
                albumView?.removeStoredAlbum()
            }
        }
    }
}
