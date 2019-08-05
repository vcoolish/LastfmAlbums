import CoreData
import UIKit


extension ArtistMO {
    fileprivate static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getUrl() -> URL? {
        if let urlString = self.url {
            return URL(string: urlString)
        }
        return nil
    }
    
    func getPhotoUrl() -> URL? {
        if let urlString = self.photoUrl {
            return URL(string: urlString)
        }
        return nil
    }
    
    static func get(from artist: ArtistDTO, context: NSManagedObjectContext) -> ArtistMO? {
        
        var artistToReturn : ArtistMO?
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
        request.predicate = NSPredicate(format: "mbid = %@", artist.name)
        
        do {
            let results = try context.fetch(request)
            if let _ : String = results.count == 1 ? "" : nil, let artist = results[0] as? ArtistMO {
                artistToReturn = artist
            } else {
                artistToReturn = create(from: artist, context: context)
            }
            
        } catch let error {
            print(error)
            return nil
        }
        
        return artistToReturn
    }
    
    
    static func create(from artist: ArtistDTO, context: NSManagedObjectContext) -> ArtistMO? {
        
        var artistToReturn : ArtistMO?
        
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = context
        
        let entity = NSEntityDescription.entity(forEntityName: "Artist",
                                                in: context)!
        
        let artistMO = ArtistMO(entity: entity, insertInto: childContext)
        artistMO.name = artist.name
        artistMO.photoUrl = artist.photoUrl?.absoluteString
        artistMO.mbid = artist.mbid
        artistMO.url = artist.url?.absoluteString
        
        if appDelegate.persistenceController.save(childContext) {
            artistToReturn = context.object(with: artistMO.objectID) as? ArtistMO
        }
        return artistToReturn
    }
}

