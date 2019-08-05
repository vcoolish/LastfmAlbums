import UIKit
import AlamofireImage

class ArtistCell : UITableViewCell {
        
    @IBOutlet weak var artistName : UILabel!
    @IBOutlet weak var listeners: UILabel!
    @IBOutlet weak var customImageView : UIImageView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.customImageView.af_cancelImageRequest()
        self.customImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        customImageView.layer.cornerRadius = customImageView.bounds.size.width / 2
        customImageView.clipsToBounds = true
        customImageView.contentMode = .scaleAspectFill
    }
    
    public func setContent(artist: Artist) {
        self.listeners.isHidden = false
        self.customImageView.isHidden = false

        self.artistName.text = artist.name
        self.listeners.text = artist.listeners != nil ? "\(getListenersPretty(artist.listeners!)) Listeners" : ""
        print(artist.photoUrl)
        print(artist.url)
        if artist.photoUrl == nil {
            setImage(UIImage(named: "AlbumMedia")!)
        }
        
    }
    
    public func setImage(_ image: UIImage) {
        self.customImageView.image = image
    }
    
    
    public func setImage(_ url: URL) {
        self.customImageView.af_setImage(withURL: url, placeholderImage: UIImage(), completion: {
            response in
            if let image = response.result.value {
                print(image)
            } else {
                self.setImage(UIImage(named: "AlbumMedia")!)
            }
        })
    }
    
    
    private func getListenersPretty(_ listeners: Int) -> String {
        let numberString = String(listeners)
        switch listeners {
        case let x where x >= 1000000:
            let number = numberString.dropLast(6)
            return "\(number) Million"
        case let x where x >= 1000:
            let number = numberString.dropLast(3)
            return "\(number) Thousand"
        case let x where x < 1000:
            return numberString
        default:
            return ""
        }
    }
}
