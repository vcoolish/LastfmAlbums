import UIKit

class AlbumVcHeaderView : UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumArtist: UILabel!
    @IBOutlet weak var albumTags: UILabel!
    
    var albumArtistSelectedCallback : (() -> ())?
    
    @objc private func artistSelected(sender: UIGestureRecognizer) {
        if let callback = albumArtistSelectedCallback {
            callback()
        }
    }
    
    override func layoutSubviews() {
        imageView.contentMode = .scaleAspectFill
        
        
        if let _ = albumArtistSelectedCallback {
            albumArtist.isUserInteractionEnabled = true
            let clickedArtist = UITapGestureRecognizer(target: self, action: #selector(artistSelected))
            albumArtist.addGestureRecognizer(clickedArtist)
        }
    }
}
