import CoreData
import AlamofireImage

class StoredAlbumsPresenter {
    
    weak private var storedAlbumsView: StoredAlbumsView?
    
    var context : NSManagedObjectContext?
    let imageDownloader = ImageDownloader()
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        context = (UIApplication.shared.delegate as! AppDelegate).persistenceController.managedObjectContext
        
        let albumsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let primarySortDescriptor = NSSortDescriptor(key: "storedDate", ascending: false)
        albumsFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: albumsFetchRequest,
            managedObjectContext: context!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return frc
    }()
    
    func attachView(view: StoredAlbumsView) {
        storedAlbumsView = view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    @objc func contextDidSave(notification: Notification) {
        if let context = context, let sender = notification.object as? NSManagedObjectContext {
            if sender != context {
                context.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
    
    func detachView() {
        storedAlbumsView = nil
    }
    
    func getObjectFor(row: Int) -> AlbumMO? {
        return fetchedResultsController.object(at: IndexPath(row: row - 1, section: 0)) as? AlbumMO
    }
}
