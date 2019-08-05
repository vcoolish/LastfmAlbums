import UIKit
import AlamofireImage
import CoreData

class SearchVC : UIViewController {
    
    typealias Defaults = Constants.Search
    fileprivate let presenter = SearchPresenter()
    
    lazy var loadingView : UIView = {
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0,y:0), size: CGSize(width:self.tableView.frame.size.width, height: 80)))
        let loadingView = showLoadingView(centerX: view.center.x, originY: 15)
        view.addSubview(loadingView)
        view.center=self.view.center
        view.isHidden = true
        return view
    }()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            if #available(iOS 11.0, *) {
                self.tableView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
            self.tableView.register(UINib(nibName: "ArtistCell", bundle: Bundle.main), forCellReuseIdentifier: "ArtistCell")
        }
    }
    
    var searchController : UISearchController! {
        didSet {
            self.searchController.searchResultsUpdater = self
            self.searchController.delegate = self
            self.searchController.searchBar.delegate = self
            
            self.searchController.hidesNavigationBarDuringPresentation = false
            self.searchController.dimsBackgroundDuringPresentation = false
            
            self.navigationItem.titleView = searchController.searchBar
            
            self.definesPresentationContext = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(view: self)
        view.addSubview(loadingView)
        self.searchController = UISearchController(searchResultsController:  nil)
        
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        presenter.detachView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.isActive = true
    }
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "searchToArtistAlbums":
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            let destination = segue.destination as? ArtistAlbumsVC

            guard let artist = presenter.artists?[indexPath.row] else {
                fatalError("Internal inconsistency upon fetching Artist")
            }
            destination?.artist = artist
            
            default:
            if let id = segue.identifier {
                print("Unknown segue: \(id)")
            }
        }
    }
}

extension SearchVC : UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) { }
    
    func didPresentSearchController(_ searchController: UISearchController) { }
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0 , section: 0)) {
            presenter.searchTimer?.invalidate()
            self.performSegue(withIdentifier: "searchToArtistAlbums", sender: cell)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: false, completion: {
            searchBar.resignFirstResponder()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return true
        }
        
        let currentText = searchBar.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        return presenter.onQueryChanged(newText: newText, currentText: currentText)
    }
}

extension SearchVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let count = presenter.artists?.count {
            if indexPath.row == count - 1 {
                presenter.onLastCellVisible()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "searchToArtistAlbums", sender: self.tableView.cellForRow(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.artists?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath) as! ArtistCell
        var photoUrl : URL?
        
        guard let artist = presenter.artists?[indexPath.row] else {
            fatalError("Internal inconsistency upon fetching Artist")
        }
        cell.setContent(artist: artist)
        photoUrl = artist.photoUrl
        
        if let url = photoUrl {
            cell.setImage(url)
        }
        return cell
    }
}

extension SearchVC: SearchView {
    
    func showLoading(isLoading: Bool) {
        loadingView.isHidden = !isLoading
    }
    
    func getQueryString() -> String? {
        return searchController.searchBar.text
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func onRequestSuccess() {
        if !presenter.isSearching {
            tableView.tableHeaderView = nil
        }
        presenter.isFetching = false
        tableView.reloadData()
    }
    
    func onRequestFail(error: String) {
        if !presenter.isSearching {
            tableView.tableHeaderView = nil
        }
        let ac = UIAlertController(title: Constants.Error.error, message: error, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
    }
}
