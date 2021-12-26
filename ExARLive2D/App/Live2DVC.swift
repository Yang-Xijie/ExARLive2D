import ARKit
import GLKit

import SceneKit
import UIKit

class Live2DViewController: GLKViewController {
    // MARK: - Properties

    let live2DViewUpdater = Live2DViewUpdater()

    /// Front View
    @IBOutlet var frontARSceneView: ARSCNView!

    /// arSesion
    var arSession: ARSession {
        return frontARSceneView.session
    }

    var live2DModel: Live2DModelOpenGL!

    var live2DView: EAGLContext!

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

        // avert system sleep after long-time no operation
        UIApplication.shared.isIdleTimerDisabled = true

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

    // allow app-defined gestures to take precedence over the system gestures
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        // .bottom: don't return to destop or show mission control when user slides up from the bottom
        // .top: don't show notification center and control center when user sildes down from the top
        return [.bottom, .top]
    }

    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

        setupSizeAndPosition()

        _ = updateFrame()
    }

    private func setupSizeAndPosition() {
        let size = UIScreen.main.bounds.size
        let defaults = UserDefaults.standard

        let zoom: Float = defaults.float(forKey: SETTINGS.key.ZOOM)

        let scx: Float = (Float)(5.6 / live2DModel.getCanvasWidth()) * zoom
        let scy: Float = (Float)(5.6 / live2DModel.getCanvasWidth() * (Float)(size.width / size.height)) * zoom
        let x: Float = defaults.float(forKey: SETTINGS.key.X)
        let y: Float = defaults.float(forKey: SETTINGS.key.Y)

        let matrix4 = SCNMatrix4(
            m11: scx, m12: 0, m13: 0, m14: 0,
            m21: 0, m22: scy, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: x, m42: y, m43: 0, m44: 1
        )
        live2DModel.setMatrix(matrix4)
    }

    func tearDownGL() {
        live2DModel = nil
        Live2DCubism.dispose()
        EAGLContext.setCurrent(live2DView)
    }

    // MARK: - GLKViewDelegate

    override func glkView(_: GLKView, drawIn _: CGRect) {
        setupSizeAndPosition()

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
