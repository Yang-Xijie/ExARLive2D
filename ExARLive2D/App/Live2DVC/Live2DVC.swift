import ARKit
import GLKit

import SceneKit
import UIKit

class Live2DViewController: GLKViewController {
    // MARK: - Properties

    /// Front View
    @IBOutlet var frontARSceneView: ARSCNView!

    /// live2D view behind
    var live2DView: EAGLContext!

    // MARK: AR

    let live2DViewUpdater = Live2DViewUpdater()

    var arSession: ARSession {
        return frontARSceneView.session
    }

    // MARK: properties

    var live2DModel: Live2DModelOpenGL!

    var lastFrame: TimeInterval = 0.0

    // MARK: - View Controller Life Cycle

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

        // MARK: set OpenGL

        setupGL()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        resetTracking()

        if isViewLoaded, view.window == nil {
            view = nil
            tearDownGL()

            if EAGLContext.current() == live2DView {
                EAGLContext.setCurrent(nil)
            }
            live2DView = nil
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        arSession.pause()
    }

    // MARK: - Instance Life Cycle

    deinit {
        self.tearDownGL()
        if EAGLContext.current() == self.live2DView {
            EAGLContext.setCurrent(nil)
        }
        self.live2DView = nil
    }

    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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

        _ = updateFrame()
    }

    func tearDownGL() {
        live2DModel = nil
        Live2DCubism.dispose()
        EAGLContext.setCurrent(live2DView)
    }

    // MARK: - GLKViewDelegate

    override func glkView(_: GLKView, drawIn _: CGRect) {
        setupSizeAndPositionOfLive2DModel()

        let r = UserDefaults.standard.integer(forKey: SETTINGS.key.RED)
        let g = UserDefaults.standard.integer(forKey: SETTINGS.key.GREEN)
        let b = UserDefaults.standard.integer(forKey: SETTINGS.key.BLUE)

        glClearColor(Float(r) / 255, Float(g) / 255, Float(b) / 255, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        let delta = updateFrame()
        live2DModel.updatePhysics(Float(delta))

        live2DModel.setParam("ParamBreath", value: Float32((cos(lastFrame) + 1.0) / 2.0))

        live2DModel.update()
        live2DModel.draw()
    }

    // MARK: - Frame Update

    func updateFrame() -> TimeInterval {
        let now = Date().timeIntervalSince1970
        let deltaTime = now - lastFrame
        lastFrame = now
        return deltaTime
    }
}
