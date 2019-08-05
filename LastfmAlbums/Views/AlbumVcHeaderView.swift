import UIKit

class AlbumVcHeaderView : UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumArtist: UILabel!
    @IBOutlet weak var albumTags: UILabel!
    @IBOutlet weak var selectAlbumButton: SelectAlbumButton!
    
    override func layoutSubviews() {
        imageView.contentMode = .scaleAspectFill
    }
}
