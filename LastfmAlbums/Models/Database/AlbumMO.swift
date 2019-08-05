import CoreData
import UIKit

extension AlbumMO {
    
    fileprivate static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    static func saveAlbumImage(_ image: UIImage, identifier: String) -> URL? {
        return saveImage(
            image: image,
            path: String(format: Constants.Files.albumFile, identifier),
            folder: Constants.Files.albumsFolder)
    }
    
    func getLocalImageURL() -> URL? {
        return getFile(
            name: String(format: Constants.Files.albumFile, self.stringHash!),
            folder: Constants.Files.albumsFolder)
    }
    
    func getLocalImagePathString() -> String? {
        return getLocalImageURL()?.path ?? nil
    }
    
    static func get(from stringHash: String) -> AlbumMO? {
        let context = appDelegate.persistenceController.managedObjectContext
        context.refreshAllObjects()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        request.predicate = NSPredicate(format: "stringHash = %@", stringHash)
        
        
        do {
            let results = try context.fetch(request)
            if let _ : Int? = results.count == 1 ? 1 : nil, let result = results[0] as? AlbumMO {
                return result
            } else {
                return nil
            }
        } catch let error {
            print(error)
            return nil
        }
    }
    
    static func delete(album: AlbumMO) -> Bool {
        var ok = false
        
        let persistentStoreCoordinator = appDelegate.persistenceController.persistentStoreCoordinator
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let albumToDelete = privateContext.object(with: album.objectID) as! AlbumMO
        let imageURL = albumToDelete.getLocalImageURL()
        
        privateContext.performAndWait {
            
            privateContext.delete(albumToDelete)
            if appDelegate.persistenceController.save(privateContext) {
                if let url = imageURL {
                    let _ = deleteFile(file: url)
                }
                ok = true
            }
        }
        
        return ok
    }
    
    static func create(from album: AlbumDTO, context: NSManagedObjectContext? = nil, withImage: UIImage? = nil) -> AlbumMO? {
        var albumToReturn : AlbumMO?
        
       
        
        var _context : NSManagedObjectContext!
        if let context = context {
            _context = context
        } else {
            let persistentStoreCoordinator = appDelegate.persistenceController.persistentStoreCoordinator
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.persistentStoreCoordinator = persistentStoreCoordinator
            
            _context = privateContext
        }
        
        guard let albumArtist = album.artist, let artist = ArtistMO.get(from: albumArtist, context: _context) else {
            return nil
        }
        
        
            
        var imageURL : URL?

        if let image = withImage, let url = saveAlbumImage(image, identifier: album.hashString) {
            imageURL = url
        }
            
        let entity = NSEntityDescription.entity(forEntityName: "Album",
                                                    in: _context)!
        let _album = AlbumMO(entity: entity, insertInto: _context)
        _album.artist = artist
        artist.addToAlbums(_album)
            
        _album.name = album.name
        _album.stringHash = album.hashString
        _album.photoUrl = album.photoUrl?.absoluteString
        _album.tags = album.tags
        _album.storedDate = Date()

        if let tracks = TrackMO.createMultiple(from: album.tracks, albumMO: _album) {
            _album.addToTracks(tracks as NSSet)
        } else {
            return nil
        }
            
        _context.performAndWait {
            if appDelegate.persistenceController.save(_context) {
                albumToReturn = _album
            
            } else if let url = imageURL {
                let _ = deleteFile(file: url)
            }
        }
        
        
        return albumToReturn

    }
}
