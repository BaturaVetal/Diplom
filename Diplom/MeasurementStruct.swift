//
//  MeasurementStruct.swift
//  Diplom
//
//  Created by Test on 18.05.2023.
//

import ARKit

struct Measurement {
    let start: SCNVector3
    let end: SCNVector3
    let distance: Float
    let vector: SCNVector3
    let halfwayPoint: SCNVector3
    let lengthOfCircle: Float
    let lengthOfSemicircle: Float
    let areaOfCircle: Float
    let areaOfSemicircle: Float
    
    init(start: SCNVector3, end: SCNVector3) {
        
        self.start = start
        self.end = end
        
        self.vector = SCNVector3Make(
            end.x - start.x,
            end.y - start.y,
            end.z - start.z
        )
        
        self.distance = sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        
        self.halfwayPoint = SCNVector3(
            start.x + vector.x / 2.0,
            start.y + vector.y / 2.0,
            start.z + vector.z / 2.0
        )
        
        self.lengthOfCircle = distance * Float.pi
        
        self.lengthOfSemicircle = distance / 2.0 * Float.pi
        
        self.areaOfCircle = distance / 2.0 * distance / 2.0 * Float.pi
        
        self.areaOfSemicircle = distance / 2.0 * distance / 2.0 * Float.pi / 2.0
    }
}
