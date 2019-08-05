import Foundation

protocol ArtistAlbumsView: class {
    func onArtistError(error: String)
    func onArtistSuccess()
    func onAlbumsError(error: String)
    func onAlbumsSuccess(albums: [Album])
    func onSingleDetailSuccess(indexPath: IndexPath)
    func getVisibleItems() -> [IndexPath]
    func reloadCollectionView(items: [IndexPath]?)
    func getArtist() -> Artist
}
