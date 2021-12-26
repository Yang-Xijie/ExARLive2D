// Live2DVS+ARSession.swift

import ARKit
import Foundation
import UIKit

// MARK: - ARSessionDelegate

extension Live2DViewController: ARSessionDelegate {
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
            self.resetTracking()
        }
    }
}
