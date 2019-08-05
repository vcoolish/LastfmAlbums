import UIKit
import AlamofireImage
import CoreData

class ArtistAlbumsVC : UIViewController {
    
    fileprivate let presenter = ArtistAlbumsPresenter()
    static let maxAlbumsNumber = 12
    
    fileprivate var artistCell : ArtistInfoHeaderCell?
    
    var artist : Artist! {
        didSet {
            presenter.attachView(view: self)
            presenter.onArtistUpdated()
        }
    }
    
//    lazy var loadingView : UIView = {
//        let loadingView = showLoadingView(centerX: view.center.x, originY: view.center.y)
//        loadingView.center = self.view.center
//        loadingView.isHidden = true
//        return loadingView
//    }()
    
    var dismissToAlbumCallback : (() -> ())? {
        didSet {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissToAlbum))
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "AlbumCell", bundle: Bundle.main), forCellWithReuseIdentifier: "AlbumCell")
            collectionView.register(UINib(nibName: "ArtistInfoHeaderCell", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ArtistInfoHeaderCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presenter.contextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        presenter.detachView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "presentAlbumFromArtist":
            let backItem = UIBarButtonItem()
            backItem.title = "Artist"
            navigationItem.backBarButtonItem = backItem
            
            let destination = segue.destination as! AlbumVC
            let indexPath = collectionView.indexPathsForSelectedItems![0]
           
            if let storedAlbum = AlbumMO.get(from: String(artist.albums![indexPath.row].hashValue)) {
                let image = storedAlbum.getLocalImagePathString() != nil ? UIImage(contentsOfFile: storedAlbum.getLocalImagePathString()!) : nil
                let album = AlbumDTO(albumMO: storedAlbum, image: image)
                album.localMode = false
                destination.albumDTO = album
            } else if let _ = artist.albums![indexPath.row].albumDetail {
                destination.albumDTO = AlbumDTO(album: artist.albums![indexPath.row], image: artist.albums![indexPath.row].loadedImage)
            }
            
            presenter.selectedAlbumIndexPath = collectionView.indexPathsForSelectedItems![0]
            
        default:
            if let id = segue.identifier {
                print("Unknown segue: \(id)")
            }
        }
    }
    
    @objc func dismissToAlbum(sender : UIBarButtonItem) {
        if let callback = dismissToAlbumCallback {
            callback()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension ArtistAlbumsVC : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        
        guard let album = artist.albums?[indexPath.row] else {
            return cell
        }
        
        if let _ = AlbumMO.get(from: String(album.hashValue)) {
            cell.storedLabel.isHidden = false
            
            cell.hasDetail = true
            album.hadDetail = true
        } else {
            cell.storedLabel.isHidden = true
            
            cell.hasDetail = album.albumDetail != nil
            album.hadDetail = album.albumDetail != nil
        }
        
        cell.setContent(album)
        
        if let loadedImage = album.loadedImage {
            cell.setImageFrom(image: loadedImage, hadDetail: album.hadDetail)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artist.albums?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if artistCell == nil {
            artistCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ArtistInfoHeaderCell", for: indexPath) as? ArtistInfoHeaderCell
            artistCell?.setActivityIndicatorView()
            artistCell?.setContent(artist)
        }
        if let detail = artist.detail {
            artistCell?.setDetailContent(detail)
        }
        return artistCell!
    }
}

extension ArtistAlbumsVC : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = artist.requestedAlbumDetails {
            presenter.requestAlbumDetail()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AlbumMO.get(from: String(artist.albums![indexPath.row].hashValue)) != nil ||
            artist.albums![indexPath.row].albumDetail != nil
        {
            self.performSegue(withIdentifier: "presentAlbumFromArtist", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 265)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 80, height: artist.albums != nil && !presenter.seeMoreLinkFooterActivated ? 0 : 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 2.0
        let cellHeight = cellWidth * (20/15)
        
        return CGSize(width: cellWidth - 8, height: cellHeight)
    }
}

extension UICollectionView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension ArtistAlbumsVC: ArtistAlbumsView {
    
    func onArtistError(error: String) {
        let ac = UIAlertController(
            title: Constants.Error.error,
            message: Constants.Error.connectionError,
            preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if self.dismissToAlbumCallback != nil {
                self.dismissToAlbum(sender: self.navigationItem.leftBarButtonItem!)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        present(ac, animated: true, completion: nil)
    }
    
    func onArtistSuccess() {
        self.navigationItem.title = artist.name
        collectionView.reloadData()
    }
    
    func reloadCollectionView(items: [IndexPath]? = nil) {
        if let items = items {
            collectionView.reloadItems(at: items)
        }
        else {
            collectionView.reloadData()
        }
    }
    
    func onAlbumsSuccess(albums: [Album]) {
        artist.albums = Array(albums.prefix(ArtistAlbumsVC.maxAlbumsNumber))
        artist.requestedAlbumDetails = Dictionary<Album,Bool>()
        collectionView.reloadData(completion: {
            self.presenter.requestAlbumDetail()
            guard let albums = self.artist.albums, albums.count > 0 else {
                return
            }
            let lastVisibleAlbumIndex = self.collectionView.indexPathsForVisibleItems.last?.row ?? 0
            
            for i in lastVisibleAlbumIndex+1...albums.count-1 {
                AlbumCell.fetchPhoto(albums[i], downloader: self.presenter.imageDownloader, completion: {})
            }
        })
    }
    
    func onAlbumsError(error: String) {
        defer {
            presenter.noFetchedAlbums = true
            self.collectionView.reloadData()
        }
        let ac = UIAlertController(title: Constants.Error.error, message: error, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in return }))
        present(ac, animated: true, completion: nil)
    }
    
    func onSingleDetailSuccess(indexPath: IndexPath) {
        if collectionView.indexPathsForVisibleItems.contains(indexPath) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func getVisibleItems() -> [IndexPath] {
        return collectionView.indexPathsForVisibleItems
    }
    
    func getArtist() -> Artist {
        return artist
    }
}
