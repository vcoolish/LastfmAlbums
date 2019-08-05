import UIKit
import AlamofireImage

class AlbumCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumArtist: UILabel!
    @IBOutlet weak var storedLabel: UILabel!
    
    var hasDetail = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.layer.cornerRadius = 5.0
        self.imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.imageView.layer.borderColor = nil
        self.imageView.layer.borderWidth = 0.0
    }
    
    public func setContent(_ album: Album) {
        self.albumName.text = album.name
        self.albumArtist.text = album.artist?.name
    }
    
    public func setSearchCellContent() {
        if let image = UIImage(named: "AddAlbum") {
            setImageFrom(image: image)
        }
    }
    
    public func setContent(_ storedAlbum: AlbumMO) {
        if storedAlbum.photoUrl == nil {
            setImageFrom(image: UIImage(named: "AlbumMedia")!)
        }
        
        self.albumName.text = storedAlbum.name
        self.albumArtist.text = storedAlbum.artist?.name
    }
    
    public func setImageFrom(image: UIImage, hadDetail: Bool = true) {
        self.imageView.image = image
       
        if !hadDetail && self.hasDetail {
            self.unsetTransparency()
            
        } else {
            self.imageView.alpha = !self.hasDetail ? 0.3 : 1.0
        }
    }
    
    private func unsetTransparency() {
        self.imageView.alpha = 1.0
    }
    
    public func setImageFrom(url: URL?, hadDetail: Bool, completion: @escaping (UIImage) -> ()) {
        
        guard let url = url else {
            return
        }
        
        self.imageView.af_setImage(withURL: url, placeholderImage: UIImage(), completion: {
            response in
            if let _image = response.result.value {
                completion(_image)
            }
        })
        
    }
    
    public static func fetchPhoto(_ album: Album, downloader: ImageDownloader, completion: @escaping () -> ()) {
        if album.loadedImage == nil, let photoUrl = album.photoUrl {
            fetchPhotoFrom(photoUrl, downloader: downloader, completion: {
                image in
                album.loadedImage = image
                completion()
            })
        }
    }
    
    public static func fetchPhoto(_ album: AlbumMO, downloader: ImageDownloader, completion: @escaping () -> ()) {
        if (album.getLocalImageURL() == nil ||  UIImage(contentsOfFile: album.getLocalImageURL()!.path) == nil), let imageUrlString = album.photoUrl, let photoUrl = URL(string: imageUrlString)  {
            fetchPhotoFrom(photoUrl, downloader: downloader, completion: {
                image in
                if let _ = AlbumMO.saveAlbumImage(image, identifier: album.stringHash!) {
                    completion()
                }
            })
        }
    }
    
    public static func fetchPhotoFrom(_ url: URL, downloader: ImageDownloader, completion: @escaping (UIImage) -> ()) {
        downloader.download(URLRequest(url: url), completion: { response in
            if let image = response.result.value {
               completion(image)
            }
        })
    }
}

