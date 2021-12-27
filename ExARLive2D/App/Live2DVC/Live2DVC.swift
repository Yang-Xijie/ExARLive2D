import ARKit
import GLKit

import SceneKit
import UIKit

class Live2DViewController: GLKViewController {
    // MARK: - Properties

    // MARK: - views

    /// front camera view
    @IBOutlet var frontARSceneView: ARSCNView!

    /// live2D view behind
    var live2DView: EAGLContext!

    // MARK: AR

    let live2DViewUpdater = Live2DViewUpdater()

    var arSession: ARSession {
        return frontARSceneView.session
    }

    // MARK: others

    var live2DModel: Live2DModelOpenGL!

    /// time stamp of the previous frame (in seconds)
    var timeStampOfPreviousFrame: TimeInterval = Date().timeIntervalSince1970

    // MARK: - setup

    override func viewDidLoad() {
        super.viewDidLoad()

        frontARSceneView.delegate = live2DViewUpdater
        frontARSceneView.session.delegate = self

        frontARSceneView.automaticallyUpdatesLighting = true

        // MARK: set live2dView

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

        // MARK: setup live2d model

        setupGL()
    }

    private func setupGL() {
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupARFaceTracking()

        if isViewLoaded, view.window == nil {
            view = nil
            tearDownGL()

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

    func tearDownGL() {
        live2DModel = nil
        Live2DCubism.dispose()
        EAGLContext.setCurrent(live2DView)
    }

    deinit {
        self.tearDownGL()
        if EAGLContext.current() == self.live2DView {
            EAGLContext.setCurrent(nil)
        }
        self.live2DView = nil
    }
}
