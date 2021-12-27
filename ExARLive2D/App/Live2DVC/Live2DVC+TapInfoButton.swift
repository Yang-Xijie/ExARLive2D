import Foundation

// MARK: - More Operations

extension Live2DViewController {
    @IBAction func tapInfoButton(_ sender: UIButton) {
        let toggleFrontViewAction = UIAlertAction(title: frontARCameraView.isHidden ? "Show Front View" : "Hide Front View", style: .default, handler: { _ in
            self.frontARCameraView.isHidden.toggle()
        })

        let openSettingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            let settingsModal = UserSettingsViewController()
            settingsModal.modalTransitionStyle = .coverVertical
            settingsModal.modalPresentationStyle = .pageSheet
            self.present(settingsModal, animated: true, completion: nil)
        })

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(toggleFrontViewAction)
        actionSheet.addAction(openSettingsAction)

        actionSheet.popoverPresentationController?.sourceView = sender

        show(actionSheet, sender: self)
    }
}
