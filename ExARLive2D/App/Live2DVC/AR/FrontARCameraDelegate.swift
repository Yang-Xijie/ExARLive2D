import ARKit
import SceneKit

class FrontARCameraDelegate: NSObject, ARSCNViewDelegate {
    // MARK: - Properties

    var live2dModel: Live2DModelOpenGL!

    private var timeofcurrent = Date().timeIntervalSince1970

    // MARK: - ARSCNViewDelegate

    /// - Tag: ARNodeTracking
    func renderer(_: SCNSceneRenderer, didAdd _: SCNNode, for _: ARAnchor) {}

    /// - Tag: ARFaceGeometryUpdate
    func renderer(_: SCNSceneRenderer, didUpdate _: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard let eyeBlinkLeft = faceAnchor.blendShapes[.eyeBlinkLeft] as? Float,
              let eyeBlinkRight = faceAnchor.blendShapes[.eyeBlinkRight] as? Float,
              let browInnerUp = faceAnchor.blendShapes[.browInnerUp] as? Float,
              let browOuterUpLeft = faceAnchor.blendShapes[.browOuterUpLeft] as? Float,
              let browOuterUpRight = faceAnchor.blendShapes[.browOuterUpRight] as? Float,
              let mouthFunnel = faceAnchor.blendShapes[.mouthFunnel] as? Float,
              let jawOpen = faceAnchor.blendShapes[.jawOpen] as? Float,
              let cheekPuff = faceAnchor.blendShapes[.cheekPuff] as? Float
        else { return }

        let newFaceMatrix = SCNMatrix4(faceAnchor.transform)
        let faceNode = SCNNode()
        faceNode.transform = newFaceMatrix

        live2dModel.setParam("ParamAngleY", value: faceNode.eulerAngles.x * -360 / Float.pi)
        live2dModel.setParam("ParamAngleX", value: faceNode.eulerAngles.y * 360 / Float.pi)
        live2dModel.setParam("ParamAngleZ", value: faceNode.eulerAngles.z * -360 / Float.pi)

        live2dModel.setParam("ParamBodyPosition", value: 10 + faceNode.position.z * 20)
        live2dModel.setParam("ParamBodyAngleZ", value: faceNode.position.x * 20)
        live2dModel.setParam("ParamBodyAngleY", value: faceNode.position.y * 20)

        live2dModel.setParam("ParamEyeBallX", value: faceAnchor.lookAtPoint.x * 2)
        live2dModel.setParam("ParamEyeBallY", value: faceAnchor.lookAtPoint.y * 2)

        live2dModel.setParam("ParamBrowLY", value: -(0.5 - browOuterUpLeft))
        live2dModel.setParam("ParamBrowRY", value: -(0.5 - browOuterUpRight))
        live2dModel.setParam("ParamBrowLAngle", value: 16 * (browInnerUp - browOuterUpLeft) - 1.6)
        live2dModel.setParam("ParamBrowRAngle", value: 16 * (browInnerUp - browOuterUpRight) - 1.6)

        live2dModel.setParam("ParamEyeLOpen", value: 1.0 - eyeBlinkLeft)
        live2dModel.setParam("ParamEyeROpen", value: 1.0 - eyeBlinkRight)

        live2dModel.setParam("ParamMouthOpenY", value: jawOpen * 1.8)
        live2dModel.setParam("ParamMouthForm", value: 1 - mouthFunnel * 2)

//        live2dModel.setParam("ParamCheek", value: cheekPuff)
//        live2dModel.setParam("ParamBreath", value: Float(cos(Double(i) * 3.0) + 1.0) / 2.0)
        live2dModel.setParam("ParamCheek", value: 0) // default value [-1.0, 1.0]

//        print(Date().timeIntervalSince1970 - timeofcurrent) // 0.0166s
        timeofcurrent = Date().timeIntervalSince1970

//        live2dModel.yxjtest()
    }
}
