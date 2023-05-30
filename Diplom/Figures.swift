//
//  Figures.swift
//  Diplom
//
//  Created by Test on 17.05.2023.
//

import ARKit


class Figures: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    func makeCylinder(start: SCNVector3, end: SCNVector3, endNode: SCNNode) {
        let measurement = Measurement(start: start, end: end)
        let cylinder = SCNCylinder(radius: 0.002, height: CGFloat(measurement.distance))
        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.position = measurement.halfwayPoint
        cylinderNode.look(at: endNode.position, up: sceneView.scene.rootNode.worldUp, localFront: SCNVector3Make(0, 1, 0))
        sceneView.scene.rootNode.addChildNode(cylinderNode)
    }
    
    func makeTorus(start: SCNVector3, end: SCNVector3, endNode: SCNNode, cameraPosition: SCNVector3) {
        let measurement = Measurement(start: start, end: end)
        let torus = SCNTorus(ringRadius: CGFloat(measurement.distance/2), pipeRadius: 0.002)
        let torusNode = SCNNode(geometry: torus)
        torusNode.position = measurement.halfwayPoint
        let directionToViewer = SCNVector3(
            cameraPosition.x - measurement.halfwayPoint.x,
            cameraPosition.y - measurement.halfwayPoint.y,
            cameraPosition.z - measurement.halfwayPoint.z
        )
        torusNode.look(at: endNode.position, up: directionToViewer, localFront: SCNVector3(1, 0, 0))
        sceneView.scene.rootNode.addChildNode(torusNode)
    }

}
