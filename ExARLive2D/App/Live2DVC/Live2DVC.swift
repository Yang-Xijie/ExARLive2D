import ARKit
import GLKit

import SceneKit
import UIKit

class Live2DViewController: GLKViewController {
    // MARK: - Properties

    /// front camera view
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

    /// time stamp of the last frame (in seconds)
    var lastFrameTimeStamp: TimeInterval = 0.0

    // MARK: - View Life Cycle

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        arSession.pause()
    }

    deinit {
        self.tearDownGL()
        if EAGLContext.current() == self.live2DView {
            EAGLContext.setCurrent(nil)
        }
        self.live2DView = nil
    }

    // MARK: - GLKViewDelegate

    override func glkView(_: GLKView, drawIn _: CGRect) {
        setupSizeAndPositionOfLive2DModel()

        let r = UserDefaults.standard.integer(forKey: SETTINGS.key.RED)
        let g = UserDefaults.standard.integer(forKey: SETTINGS.key.GREEN)
        let b = UserDefaults.standard.integer(forKey: SETTINGS.key.BLUE)

        glClearColor(Float(r) / 255, Float(g) / 255, Float(b) / 255, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        let delta = UpdateFrame()
        live2DModel.updatePhysics(Float(delta))



        live2DModel.update()
        live2DModel.draw()
    }

    // MARK: - Frame Update

    
    /// update rendering a frame
    func UpdateFrame() -> TimeInterval {
        let now = Date().timeIntervalSince1970
        let deltaTime = now - lastFrameTimeStamp
        lastFrameTimeStamp = now
        return deltaTime
    }
}
