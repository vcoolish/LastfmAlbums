import UIKit

func showLoadingView(centerX: CGFloat, originY: CGFloat) -> UIView {
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    actInd.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: 30,height: 30))
    actInd.style = UIActivityIndicatorView.Style.whiteLarge
    actInd.center = CGPoint(x: centerX, y: originY)
    actInd.startAnimating()
    
    return actInd
}

