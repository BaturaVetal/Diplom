//
//  ViewController.swift
//  Diplom
//
//  Created by Test on 15.05.2023.
//

import ARKit


class ViewController: Figures {
    
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var aim: UILabel!
    @IBOutlet weak var notReady: UILabel!
    
    var isMeasuring = false
    var activeStartingPoint: SCNVector3!
    var cylinderNode = SCNNode()
    var torusNode = SCNNode()
    var touchesOnButtonCounter = 0
    var seccount = 0
    
    var trackingState: ARCamera.TrackingState!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the view's delegate
        sceneView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration with plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        //Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        //Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        //Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    
    @IBAction func Button(_ sender: Any) {
        if getTrackigDescription() == "READY TO MEASURE" {
            touchesOnButtonCounter += 1
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.prog()
        }
    }
    
    func getTrackigDescription() -> String {
        var description = ""
        if let t = trackingState {
            switch(t) {
            case .notAvailable:
                description = "TRACKING UNAVAILABLE"
            case .normal:
                description = "READY TO MEASURE"
            case .limited(let reason):
                switch reason {
                case .excessiveMotion:
                    description = "TRACKING LIMITED - Too much camera movement"
                case .insufficientFeatures:
                    description = "TRACKING LIMITED - Not enough surface detail"
                case .initializing:
                    description = "INITIALIZING"
                case .relocalizing:
                    description = "TRACKING LIMITED - Attempting to resume after an interruption"
                @unknown default:
                    description = "TRACKING LIMITED - Unknown error"
                }
            }
        }
        return description
    }
    
    func prog() {
        
        if getTrackigDescription() == "READY TO MEASURE" {
            
            statusTextView.isHidden = false
            aim.isHidden = false
            if seccount < 100 {
                notReady.text = getTrackigDescription()
                seccount += 1
            } else {
                notReady.isHidden = true
            }
            
            guard let hitResult = self.sceneView.hitTest(self.sceneView.center, types: .featurePoint).first else {
                return
            }
            
            let point = SCNVector3Make(hitResult.worldTransform.columns.3.x,
                                       hitResult.worldTransform.columns.3.y,
                                       hitResult.worldTransform.columns.3.z)
            
            if self.touchesOnButtonCounter == 1 {
                
                if isMeasuring == false {
                    activeStartingPoint = point
                }
                
                isMeasuring = true
                
                let measurement = Measurement(start: activeStartingPoint, end: point)
                
                deleteNode(cylinderNode)
                deleteNode(torusNode)
                
                let endNode = SCNNode()
                endNode.position = point
                makeCylinder(start: activeStartingPoint, end: point, endNode: endNode)
                
                guard let cameraNode = sceneView.pointOfView else {
                    return
                }
                let cameraPosition = cameraNode.worldPosition
                makeTorus(start: activeStartingPoint, end: point, endNode: endNode, cameraPosition: cameraPosition)
                
                setStatusText(measurement: measurement)
                
            } else {
                isMeasuring = false
                touchesOnButtonCounter = 0
            }
        } else {
            seccount = 0
            statusTextView.isHidden = true
            aim.isHidden = true
            notReady.isHidden = false
            notReady.text = getTrackigDescription()
        }
        
    }
    
    func deleteNode(_ node: SCNNode) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
    func setStatusText(measurement: Measurement) {
        var text = "Length of\t\t\t\t·Diameter: \(String(format: "%.2f cm", measurement.distance * 100.0))"
        text += "\n·Circle: \(String(format: "%.2f cm", measurement.lengthOfCircle * 100.0))"
        text += "\t\t\t\t·Semicircle: \(String(format: "%.2f cm", measurement.lengthOfSemicircle * 100.0))"
        text += "\nArea of \n·Circle: \(String(format: "%.2f cm²", measurement.areaOfCircle * 10000.0))"
        text += "\t\t·Semicircle: \(String(format: "%.2f cm²", measurement.areaOfSemicircle * 10000.0))"

        statusTextView.text = text
    }
    
}
