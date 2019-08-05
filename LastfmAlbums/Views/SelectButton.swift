import UIKit
@IBDesignable
public class SelectButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        customInitialization()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInitialization()
    }
    
    private func customInitialization() {
        setState()
    }
    

    private func setState() {
        if self.isSelected {
            self.setImage(UIImage(named: "Selected") , for: UIControl.State.normal)
        } else {
            self.setImage(UIImage(named: "Unselected") , for: UIControl.State.normal)
        }
    }

    override public func prepareForInterfaceBuilder() {
        customInitialization()
    }
    
    override public var isSelected: Bool {
        didSet {
            setState()
        }
    }
}
