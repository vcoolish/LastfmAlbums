import UIKit

extension UIViewController: StoryboardInitializable { }

protocol StoryboardInitializable {
    static var identifier: String { get }
}

extension StoryboardInitializable where Self: UIViewController {
    
    static func initFromStoryboard(name: String? = nil) -> Self? {
        let storyboard = UIStoryboard(name: name ?? identifier, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? Self
    }
}

extension UIViewController {
    
    var identifier: String {
        return String(describing: type(of: self))
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
