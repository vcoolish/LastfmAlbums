import UIKit

class SelectAlbumButton : UIButton {
    
    var selection = false
    var onSave : (() -> ())!
    var onDelete: (() -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    @objc func buttonClicked(_ sender: Any?) {
        selection = !selection
        if selection {
            onSave()
            setImage(UIImage(named: "Selected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            onDelete()
            setImage(UIImage(named: "Unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
}
