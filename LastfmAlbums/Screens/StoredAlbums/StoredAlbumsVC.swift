import UIKit
import CoreData
import AlamofireImage

class StoredAlbumsVC: UIViewController, StoredAlbumsView {
    
    fileprivate let presenter = StoredAlbumsPresenter()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(
                UINib(nibName: "AlbumCell", bundle: Bundle.main),
                forCellWithReuseIdentifier: "AlbumCell")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try presenter.fetchedResultsController.performFetch()
            self.collectionView.reloadData()
        } catch {
            print("An error occurred")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.attachView(view: self)
        
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        presenter.detachView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "presentAlbumFromHome":
            let destination = segue.destination as? AlbumVC
            let indexPath = collectionView.indexPathsForSelectedItems![0]
            let albumMO = presenter.fetchedResultsController
                .object(at: IndexPath(row: indexPath.row - 1, section: 0)) as? AlbumMO
            if let album = albumMO {
                var image: UIImage?
                if let imagePath = album.getLocalImagePathString() {
                    image = UIImage(contentsOfFile: imagePath)
                }
                destination?.albumDTO = AlbumDTO(albumMO: album, image: image)
            }
        default:
            if let id = segue.identifier {
                print("Unknown segue: \(id)")
            }
        }
    }
}

extension StoredAlbumsVC : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell

        if indexPath.row == 0 {
            cell.setSearchCellContent()
        } else {
            if let albumMO = presenter.getObjectFor(row: indexPath.row) {
            
                cell.setContent(albumMO)
                if let imageLocalUrl = albumMO.getLocalImageURL(), let image = UIImage(contentsOfFile: imageLocalUrl.path) {
                    cell.setImageFrom(image: image)
                } else {
                    AlbumCell.fetchPhoto(albumMO, downloader: presenter.imageDownloader, completion: {
                        self.collectionView.reloadItems(at: [indexPath])
                    })
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = presenter.fetchedResultsController.sections {
            let currentSection = sections[0]
            return currentSection.numberOfObjects + 1
        } else {
            return 1
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyAlbumsHeaderCell", for: indexPath)
    }
    
}

extension StoredAlbumsVC : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: indexPath.row == 0 ? "searchSegue" : "presentAlbumFromHome", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.bounds.width / 3.0
        let cellHeight = cellWidth * (1.5)
        
        return CGSize(width: cellWidth - CGFloat(Constants.Dimensions.safeMargin), height: cellHeight)
    }
}

