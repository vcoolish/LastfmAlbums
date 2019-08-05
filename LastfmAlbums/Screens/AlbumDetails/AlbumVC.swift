import UIKit
import AlamofireImage

class AlbumVC : UIViewController {
    
    @IBOutlet var albumInfoHeader: AlbumVcHeaderView!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var barItem: UINavigationItem!
    
    fileprivate var selectAlbumButton : SelectAlbumButton?
    
    var albumDTO: AlbumDTO!
    
    fileprivate let presenter = AlbumPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(view: self)
        
        self.navigationItem.title = albumDTO.name
        self.tableView.tableHeaderView = albumInfoHeader
        
        presenter.setAlbumImage(albumInfoHeader: albumInfoHeader)

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setupBarButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        presenter.detachView()
    }
    
    @objc func back(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupBarButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(AlbumVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        var buttons = [UIBarButtonItem]()
        if albumDTO.localMode {
            albumInfoHeader.albumArtistSelectedCallback = enterArtist
            buttons.append(UIBarButtonItem(
                title: "Artist Page",
                style: .plain,
                target: self,
                action: #selector(enterArtistSelector)
            ))
        }
        selectAlbumButton = UIBarButtonItem(
            image: UIImage(named: "Unselected")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: target,
            action: #selector(SelectAlbumButton.buttonClicked)) as? SelectAlbumButton
        if let button = selectAlbumButton {
            buttons.append(button)
        }
        self.navigationItem.rightBarButtonItem = selectAlbumButton
        selectAlbumButton?.onSave = presenter.saveAlbum
        selectAlbumButton?.onDelete = presenter.deleteAlbum
        
        if let _ = albumDTO.storedAlbum {
            selectAlbumButton?.isSelected = true
            selectAlbumButton?.image = UIImage(named: "Selected")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    @objc func enterArtistSelector(sender: UIBarButtonItem) {
        enterArtist()
    }
    
    private func enterArtist() {
        if let storedArtist = albumDTO.storedAlbum?.artist,
            let artistAlbumsVC =  ArtistAlbumsVC.initFromStoryboard(name: "ArtistAlbums")
        {
            let artist = Artist(from: storedArtist)
            
            artistAlbumsVC.artist = artist
//            artistAlbumsVC.dismissToAlbumCallback = {
//                self.albumHeaderCell!.saveSwitch.setOn(AlbumMO.get(from: self.albumDTO.hashString) != nil, animated: false)
//            }
            let nav = UINavigationController(rootViewController: artistAlbumsVC)
            self.present(nav, animated: true, completion: nil)
        }
    }
}

extension AlbumVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumDTO.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        
        let track = albumDTO.tracks[indexPath.row]
        
        cell.trackNr.text = String(track.number)
        cell.name.text = track.title
        cell.duration.text = track.lengthStatic
        
        return cell
    }
}

extension AlbumVC: AlbumView {
    func removeStoredAlbum() {
        albumDTO.storedAlbum = nil
    }
    
    func getAlbumDTO() -> AlbumDTO {
        return self.albumDTO
    }
}
