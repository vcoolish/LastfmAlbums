import UIKit
import AlamofireImage

class ArtistInfoHeaderCell : UICollectionReusableView {
    
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var seeMore: UIButton!
    
    @IBOutlet weak var artistInfoStatic: UILabel!
    @IBOutlet weak var artistAlbumsStatic: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var loadingView : UIView?
    var artistInfoCallback : (() -> ())?
    var url : URL?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    public func setContent(_ artist: Artist) {
        
        if let url = artist.photoUrl {
            self.imageView.af_setImage(withURL: url, placeholderImage: UIImage(), completion: {
                response in
                if let image = response.result.value {
                    self.imageView.image = image
                }
            })
        }
        if let url = artist.url {
            self.url = url
        }
    }
    
    public func setDetailContent(_ detail: ArtistInfo) {
        
        if let view = loadingView {
            view.removeFromSuperview()
        }
        tags.isHidden = false
        infoLabel.isHidden = false
        artistInfoStatic.isHidden = false
        
        infoLabel.text = detail.description
        tags.text = detail.getTagsString()
    }
    
    public func setArtistInfoCallback(_ callback: @escaping () -> ()) {
        self.artistInfoCallback = callback
    }
    
    public func setActivityIndicatorView() {
        loadingView = showLoadingView(centerX: self.center.x, originY: imageView.frame.maxY + 12)
        self.addSubview(loadingView!)
    }
}
