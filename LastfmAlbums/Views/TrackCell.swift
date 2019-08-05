import UIKit

class TrackCell : UITableViewCell {
    @IBOutlet weak var trackNr : UILabel!
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var duration : UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackNr.text = (trackNr.text ?? "") == "" ? "" : trackNr?.text
    }
}
