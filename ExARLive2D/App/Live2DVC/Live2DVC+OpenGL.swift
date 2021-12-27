// Live2DVC+OpenGL.swift

import Foundation
extension Live2DViewController {
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

        _ = UpdateFrame()
    }

    func tearDownGL() {
        live2DModel = nil
        Live2DCubism.dispose()
        EAGLContext.setCurrent(live2DView)
    }
}
