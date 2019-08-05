import CoreData
import AlamofireImage

class ArtistAlbumsPresenter {
    
    weak private var artistAlbumsView: ArtistAlbumsView?

    var noFetchedAlbums = false
    var seeMoreLinkFooterActivated = false
    var selectedAlbumIndexPath : IndexPath?
    let imageDownloader = ImageDownloader()
    
    func attachView(view: ArtistAlbumsView) {
        artistAlbumsView = view
    }
    
    func detachView() {
        artistAlbumsView = nil
    }
    
    func onArtistUpdated() {
        if let artist = self.artistAlbumsView?.getArtist() {
            if artist.detail == nil && artist.mbid != nil {
                getArtistInfo(
                    artistId: artist.mbid!,
                    onSuccess: { [weak self] artistInfo in
                        if let context = self {
                            artist.detail = artistInfo
                            context.artistAlbumsView?.onArtistSuccess()
                            context.albumRequest(artist)
                        }
                        else { return }
                    },
                    onError: { [weak self] error in
                        self?.artistAlbumsView?.onArtistError(error: error)
                })
            }
        }
    }
    
    @objc func contextDidSave(notification: Notification) {
        
        if let _ = notification.object as? NSManagedObjectContext, let selectedIndexPath = selectedAlbumIndexPath {
            if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
                
                if let album = self.artistAlbumsView?.getArtist().albums?[selectedIndexPath.row],
                    let _ = album.albumDetail
                {
                    self.artistAlbumsView?.reloadCollectionView(items: [selectedIndexPath])
                    return
                }
                
                requestSingleAlbumDetail(indexPath: selectedIndexPath)
            }
            if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
                self.artistAlbumsView?.reloadCollectionView(items: [selectedIndexPath])
            }
        }
    }
    
    
    
    private func albumRequest(_ artist: Artist) {
        getTopAlbums(
            artist: artist,
            onSuccess: { [weak self] albums in
                if let context = self {
                    context.seeMoreLinkFooterActivated = albums.count > ArtistAlbumsVC.maxAlbumsNumber && artist.url != nil
                    context.artistAlbumsView?.onAlbumsSuccess(albums: albums)
                }
            },
            onError: { [weak self] error in
                self?.artistAlbumsView?.onAlbumsError(error: error)
        })
    }
    
    func requestAlbumDetail() {
        if let artist = artistAlbumsView?.getArtist(), let albums = artistAlbumsView?.getArtist().albums {
            if let visibleAlbums = self.artistAlbumsView?.getVisibleItems() {
                for indexPath in visibleAlbums {
                    let album = albums[indexPath.row]
                    
                    AlbumCell.fetchPhoto(album, downloader: self.imageDownloader, completion: {
                        self.artistAlbumsView?.reloadCollectionView(items: [indexPath])
                    })
                    if let index = artist.albums?.firstIndex(of: album),
                        let _ = AlbumMO.get(from: String(artist.albums![index].hashValue)),
                        let _ = artist.albums?[index].albumDetail,
                        artist.requestedAlbumDetails![album] == true
                    {
                        continue
                    }
                    artist.requestedAlbumDetails?[album] = true
                    requestSingleAlbumDetail(indexPath: indexPath)
                }
            }
        }
    }
    
    private func requestSingleAlbumDetail(indexPath: IndexPath) {
        if let albums = artistAlbumsView?.getArtist().albums {
            let album = albums[indexPath.row]
            getAlbumInfo(
                album: album,
                onSuccess: { [weak self] albumDetail in
                    album.albumDetail = albumDetail
                    self?.artistAlbumsView?.onSingleDetailSuccess(indexPath: indexPath)
                },
                onError: { _ in }
            )
        }
    }
}
