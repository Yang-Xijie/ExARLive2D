import Foundation

extension Live2DViewController {
    // MARK: - Device orientation

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let isLandscape = size.width / size.height > 1

        let scale: Float = isLandscape ? 2.6 : 5.6
        let scx: Float = (Float)(scale / live2DModel.getCanvasWidth())
        let scy: Float = (Float)(scale / live2DModel.getCanvasWidth() * (Float)(size.width / size.height))
        let x: Float = 0
        let y: Float = isLandscape ? -2.4 : -0.8

        let matrix4 = SCNMatrix4(
            m11: scx, m12: 0, m13: 0, m14: 0,
            m21: 0, m22: scy, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: x, m42: y, m43: 0, m44: 1
        )
        live2DModel.setMatrix(matrix4)
    }
}
