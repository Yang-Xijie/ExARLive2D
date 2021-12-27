// Live2DVC+OpenGL.swift

import Foundation
extension Live2DViewController {
    // MARK: - GLKViewDelegate

    override func glkView(_: GLKView, drawIn _: CGRect) {
        setupSizeAndPositionOfLive2DModel()

        // MARK: background color

        let r = UserDefaults.standard.integer(forKey: SETTINGS.key.RED)
        let g = UserDefaults.standard.integer(forKey: SETTINGS.key.GREEN)
        let b = UserDefaults.standard.integer(forKey: SETTINGS.key.BLUE)

        glClearColor(Float(r) / 255, Float(g) / 255, Float(b) / 255, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        // MARK: update frame

        // get time intercal to update physics (in seconds)
        let deltaTimeInterval = Date().timeIntervalSince1970 - timeStampOfPreviousFrame // The first frame may not be correct
        print(deltaTimeInterval) // FIXME: why only 30 fps??? 0.033
        live2DModel.updatePhysics(Float(deltaTimeInterval))
        timeStampOfPreviousFrame = Date().timeIntervalSince1970

        live2DModel.update()
        live2DModel.draw()
    }

    // MARK: - Live2D OpenGL setup

    func setupGL() {
        EAGLContext.setCurrent(live2DView)

        Live2DCubism.initL2D()
        print(Live2DCubism.live2DVersion() ?? "cannot get Live2DCubism.live2DVersion")

        let jsonFile = "hiyori_pro_t10.model3"

        guard let jsonPath = Bundle.main.path(forResource: jsonFile, ofType: "json") else {
            print("Failed to find model json file")
            return
        }

        live2DModel = Live2DModelOpenGL(jsonPath: jsonPath)
        live2DViewUpdater.live2dModel = live2DModel

        for index in 0 ..< live2DModel.getNumberOfTextures() {
            let fileName = live2DModel.getFileName(ofTexture: index)!
            let filePath = Bundle.main.path(forResource: fileName, ofType: nil)!
            let textureInfo = try! GLKTextureLoader.texture(withContentsOfFile: filePath, options: [GLKTextureLoaderApplyPremultiplication: false, GLKTextureLoaderGenerateMipmaps: true])

            let num = textureInfo.name
            live2DModel.setTexture(Int32(index), to: num)
        }

        live2DModel.setPremultipliedAlpha(true)

        self.setupSizeAndPositionOfLive2DModel()

//        lastFrameTimeStamp = Date().timeIntervalSince1970
    }

    func tearDownGL() {
        live2DModel = nil
        Live2DCubism.dispose()
        EAGLContext.setCurrent(live2DView)
    }
}
