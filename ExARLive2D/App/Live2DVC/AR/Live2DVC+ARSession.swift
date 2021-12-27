import ARKit
import Foundation
import UIKit

// MARK: - ARSessionDelegate

extension Live2DViewController: ARSessionDelegate {
    /// ARFaceTrackingSetup
    func setupARFaceTracking() {
        // check if the device supports ARFaceTracking
        guard ARFaceTrackingConfiguration.isSupported else { return }

        let configuration = ARFaceTrackingConfiguration()
        // When you enable the `isLightEstimationEnabled` setting, a face-tracking configuration estimates directional and environmental lighting (an `ARDirectionalLightEstimate` object) by referring to the detected face as a light probe. [no need for now]
        // true: CPU 51% Memory 164MB
        // false: CPU 45% Memory 178MB
        configuration.isLightEstimationEnabled = false
        configuration.maximumNumberOfTrackedFaces = 1 // default value is one

        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func session(_: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }

        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion,
        ]
        let errorMessage = messages.compactMap { $0 }.joined(separator: "\n")

        DispatchQueue.main.async {
            print("The AR session failed. ::" + errorMessage)
        }
    }

    func sessionWasInterrupted(_: ARSession) {}

    func sessionInterruptionEnded(_: ARSession) {
        DispatchQueue.main.async {
            self.setupARFaceTracking()
        }
    }
}
