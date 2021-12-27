import Foundation

extension Live2DViewController {
    // MARK: - update GLKView

    override func glkView(_: GLKView, drawIn _: CGRect) {
        updateSizeAndPositionOfLive2DModel()

        // MARK: background color

        let r = UserDefaults.standard.integer(forKey: USER_SETTINGS.key.RED)
        let g = UserDefaults.standard.integer(forKey: USER_SETTINGS.key.GREEN)
        let b = UserDefaults.standard.integer(forKey: USER_SETTINGS.key.BLUE)

        glClearColor(Float(r) / 255, Float(g) / 255, Float(b) / 255, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        // MARK: update frame

        // get time intercal to update physics (in seconds)
        let deltaTimeInterval = Date().timeIntervalSince1970 - timeStampOfPreviousFrame // The first frame may not be correct
//        print(deltaTimeInterval) // FIXME: why only 30 fps??? 0.033s AR render is 0.0166s
        live2DModel.updatePhysics(Float(deltaTimeInterval))
        timeStampOfPreviousFrame = Date().timeIntervalSince1970

        live2DModel.update()
        live2DModel.draw()
    }

    private func updateSizeAndPositionOfLive2DModel() {
        let size = UIScreen.main.bounds.size

        let zoom: Float = UserDefaults.standard.float(forKey: USER_SETTINGS.key.ZOOM)
        let x: Float = UserDefaults.standard.float(forKey: USER_SETTINGS.key.X)
        let y: Float = UserDefaults.standard.float(forKey: USER_SETTINGS.key.Y)

        let scx: Float = (Float)(5.6 / live2DModel.getCanvasWidth()) * zoom
        let scy: Float = (Float)(5.6 / live2DModel.getCanvasWidth() * (Float)(size.width / size.height)) * zoom

        let matrix4 = SCNMatrix4(
            m11: scx, m12: 0, m13: 0, m14: 0,
            m21: 0, m22: scy, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: x, m42: y, m43: 0, m44: 1
        )
        live2DModel.setMatrix(matrix4)
    }
}
