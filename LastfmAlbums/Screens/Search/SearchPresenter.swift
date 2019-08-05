import CoreData
import AlamofireImage

class SearchPresenter {
    
    weak private var searchView: SearchView?
    
    var searchTimer: Timer?
    fileprivate var askedPagination = Constants.defaultPagination
    var currentPagination : Pagination?
    typealias Strings = Constants.Search
    var artists : [Artist]?
    var paginatedArtists = Dictionary<Pagination,PaginatedArtists>()
    var isSearching = false
    var isFetching = false
    
    fileprivate var context : NSManagedObjectContext?
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        context = (UIApplication.shared.delegate as! AppDelegate).persistenceController.managedObjectContext
        
        let searchFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentSearch")
        let primarySortDescriptor = NSSortDescriptor(key: "time", ascending: false)
        searchFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: searchFetchRequest,
            managedObjectContext: context!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return frc
    }()
    
    func attachView(view: SearchView) {
        searchView = view
    }
    
    private func performSearch(_ query: String? = nil) {
        print("searching \(query ?? searchView?.getQueryString()) page: \(self.askedPagination.page) ")
        searchView?.showLoading(isLoading: true)
        
        if query != nil {
            self.paginatedArtists = Dictionary<Pagination, PaginatedArtists>()
            self.artists = nil
            self.askedPagination = Constants.defaultPagination
            self.currentPagination = nil
            searchView?.reloadData()
        } else {
            searchView?.showLoading(isLoading: false)
        }
        let currentQueryString = searchView?.getQueryString()
        if query != nil || currentQueryString != nil {
            getArtistSearch(
                query: query ?? currentQueryString!,
                pagination: self.askedPagination,
                onSuccess: { [weak self] paginatedArtists in
                    if let context = self {
                        context.currentPagination = Pagination(startIndex: paginatedArtists.startIndex, page: paginatedArtists.page, total:      paginatedArtists.total)
                        
                        context.paginatedArtists[context.currentPagination!] = paginatedArtists
                        
                        if context.artists == nil {
                            context.artists = [Artist]()
                        }
                        
                        context.artists?.append(contentsOf: context.paginatedArtists[context.currentPagination!]!.artists)
                        
                        context.searchView?.onRequestSuccess()
                        context.searchView?.showLoading(isLoading: false)
                    }
                }, onError: { [weak self] error in
                    self?.searchView?.onRequestFail(error: error)
                    self?.searchView?.showLoading(isLoading: false)
            })
        }
        
        self.isFetching = true
    }
    
    func detachView() {
        searchView = nil
    }
    
    @objc private func performSearchTimer(_ timer : Timer) {
        isSearching = false
        
        if !isFetching {
            performSearch(timer.userInfo as? String)
        }
    }
    
    func onQueryChanged(newText: String, currentText: String) -> Bool {
        if newText.count < Strings.minQueryLength
            || ( newText.count < currentText.count && newText.count < Strings.minQueryLength )  {
            searchTimer?.invalidate()
            return true
        }
        
        isSearching = true
        if newText.count >= Strings.minQueryLength && newText.count % 3 == 0 && !isFetching {
            performSearch(newText)
        }
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(timeInterval: Strings.searchInterval, target: self, selector: #selector(performSearchTimer), userInfo: newText, repeats: false)
        
        return true
    }
    
    func onLastCellVisible() {
        if isSearching || isFetching {
            return
        }
        if let askedPagination = getNextPage() {
            searchTimer?.invalidate()
            
            self.askedPagination = askedPagination
            searchView?.showLoading(isLoading: true)
            self.isFetching = true
            performSearch()
        }
    }
    
    
    func getNextPage() -> Pagination? {

        if let pagination = currentPagination, let searchBarText = searchView?.getQueryString() {
            
            let decrementNumber = (Strings.pageDecrement * (searchBarText.count - Strings.minQueryLength))
            if (pagination.page + decrementNumber + 1 < Strings.maxPageNumber) &&
                (pagination.startIndex + Strings.maxResults < pagination.total)
            {
                let askedPagination = Pagination(startIndex: 0, page: pagination.page + 1, total: pagination.total)
                
                if self.paginatedArtists[askedPagination] != nil {
                    return nil
                }
                return askedPagination
            }
        }
        return nil
    }
}
