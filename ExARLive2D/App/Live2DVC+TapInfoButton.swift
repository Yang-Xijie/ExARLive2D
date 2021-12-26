// Live2DVC+TapInfoButton.swift

import Foundation

// MARK: - More Operations

extension Live2DViewController {
    @IBAction func tapInfoButton(_ sender: UIButton) {
        let toggleFrontView = UIAlertAction(title: frontARSceneView.isHidden ? "Show Front View" : "Hide Front View", style: .default, handler: { _ in
            self.frontARSceneView.isHidden.toggle()
        })

        let settings = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            let settingsModal = SettingController()
            settingsModal.modalTransitionStyle = .coverVertical
            settingsModal.modalPresentationStyle = .pageSheet
            self.present(settingsModal, animated: true, completion: nil)
        })

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(toggleFrontView)
        actionSheet.addAction(settings)

        actionSheet.addAction(UIAlertAction(title: "Cacnel", style: .cancel, handler: nil))

        actionSheet.popoverPresentationController?.sourceView = sender

        show(actionSheet, sender: self)
    }
}
