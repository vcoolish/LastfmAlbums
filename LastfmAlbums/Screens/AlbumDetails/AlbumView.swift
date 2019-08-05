import Foundation

protocol AlbumView: class {
    func getAlbumDTO() -> AlbumDTO
    func removeStoredAlbum()
}
