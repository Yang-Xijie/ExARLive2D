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

    /// time stamp of the previous frame (in seconds)
    var timeStampOfPreviousFrame: TimeInterval = Date().timeIntervalSince1970

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
}
