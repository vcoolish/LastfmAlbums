import UIKit
import AlamofireImage

class AlbumVC : UIViewController {
    
    @IBOutlet var albumInfoHeader: AlbumVcHeaderView!
    @IBOutlet weak var tableView : UITableView!
    
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
        setupButtons()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        presenter.detachView()
    }
    
    @objc func back(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupButtons() {
        albumInfoHeader.selectAlbumButton.onSave = presenter.saveAlbum
        albumInfoHeader.selectAlbumButton.onDelete = presenter.deleteAlbum
        
        if let _ = albumDTO.storedAlbum {
            albumInfoHeader.selectAlbumButton.selection = true
            albumInfoHeader.selectAlbumButton.setImage(
                UIImage(named: "Selected")?.withRenderingMode(.alwaysOriginal),
                for: .normal)
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
