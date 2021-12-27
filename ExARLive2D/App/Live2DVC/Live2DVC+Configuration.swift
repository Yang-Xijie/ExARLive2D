import Foundation
import UIKit

extension Live2DViewController {
    // MARK: hide status bar

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: prevent system gestures

    // allow app-defined gestures to take precedence over the system gestures
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        // .bottom: don't return to destop or show mission control when user slides up from the bottom
        // .top: don't show notification center and control center when user sildes down from the top
        return [.bottom, .top]
    }

    // MARK: memory management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
