import UIKit

class SelectAlbumButton : UIBarButtonItem {
    
    var isSelected = false
    var onSave : (() -> ())!
    var onDelete: (() -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.action = #selector(buttonClicked)
    }
    
    @objc func buttonClicked(button: UIBarButtonItem) {
        isSelected = !isSelected
        if isSelected {
            onDelete()
        } else {
            onSave()
        }
    }
}
