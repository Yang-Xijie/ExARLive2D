import ARKit
import GLKit

import SceneKit
import UIKit

class Live2DViewController: GLKViewController {
    // MARK: - Properties

    // MARK: views

    /// front camera view
    @IBOutlet var frontARCameraView: ARSCNView!

    /// live2D view behind
    var live2DView: EAGLContext!

    // MARK: AR

    let frontARCameraDelegate = FrontARCameraDelegate()

    var arSession: ARSession {
        return frontARCameraView.session
    }

    // MARK: others

    var live2DModel: Live2DModelOpenGL!

    /// time stamp of the previous frame (in seconds)
    var timeStampOfPreviousFrame: TimeInterval = Date().timeIntervalSince1970

    // MARK: - setup

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: setup `frontARCameraView`

        frontARCameraView.delegate = frontARCameraDelegate
        frontARCameraView.session.delegate = self

        // MARK: setup `live2DView`

        live2DView = EAGLContext(api: .openGLES2)
        if live2DView == nil {
            print("Failed to create ES context")
            return
        }
        guard let view = self.view as? GLKView else {
            print("Failed to cast view to GLKView")
            return
        }
        view.context = live2DView

        // MARK: setup `live2DModel`

        SetupLive2DModel()

        // MARK: setup `frontARCameraDelegate`

        frontARCameraDelegate.live2dModel = live2DModel
    }

    private func SetupLive2DModel() {
        EAGLContext.setCurrent(live2DView)

        Live2DCubism.initL2D()
        print(Live2DCubism.live2DVersion() ?? "cannot get Live2DCubism.live2DVersion")

        let jsonFile = "hiyori_pro_t10.model3"

        guard let jsonPath = Bundle.main.path(forResource: jsonFile, ofType: "json") else {
            print("Failed to find model json file")
            return
        }

        live2DModel = Live2DModelOpenGL(jsonPath: jsonPath)

        for index in 0 ..< live2DModel.getNumberOfTextures() {
            let fileName = live2DModel.getFileName(ofTexture: index)!
            let filePath = Bundle.main.path(forResource: fileName, ofType: nil)!
            let textureInfo = try! GLKTextureLoader.texture(withContentsOfFile: filePath, options: [GLKTextureLoaderApplyPremultiplication: false, GLKTextureLoaderGenerateMipmaps: true])

            let num = textureInfo.name
            live2DModel.setTexture(Int32(index), to: num)
        }

        live2DModel.setPremultipliedAlpha(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupARFaceTracking()

        if isViewLoaded, view.window == nil {
            view = nil

            live2DModel = nil
            Live2DCubism.dispose()
            EAGLContext.setCurrent(live2DView)

            if EAGLContext.current() == live2DView {
                EAGLContext.setCurrent(nil)
            }
            live2DView = nil
        }
    }

    // MARK: - end

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        arSession.pause()
    }

    deinit {
        live2DModel = nil
        Live2DCubism.dispose()
        EAGLContext.setCurrent(live2DView)

        if EAGLContext.current() == self.live2DView {
            EAGLContext.setCurrent(nil)
        }
        self.live2DView = nil
    }
}
