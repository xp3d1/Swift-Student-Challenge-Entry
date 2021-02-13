import Foundation
import GameKit
import SpriteKit
import SwiftUI

public class Car:SKSpriteNode{
    var carSpeed:Double?
    var alive:Bool = true
    var vision:[Double] = []
    var aiClient:Client?
    var fitness:Double = 0
    var checkpoint:Int = 0
    
    public func calculateFitness(){
        fitness = Double(checkpoint) * 50
        if (checkpoint != checkpointsCount){
            let check = scene!.childNode(withName: "//" + String(checkpoint + 1)) as! Checkpoint
            fitness += Double(3000/position.distance(point: check.position))
        }else{
            fitness += 1000
            alive = false
        }
    }
    
    public func update(scene: SKScene){
        
        for case let rTrace as RayCastNode in self.children{
            self.vision.append(Double(rTrace.rayCast(scene: scene)))
        }
        self.zRotation += CGFloat(((self.aiClient!.calculate(array: self.vision)[0])*0.2)-0.1) // moves rotation based on vision
        self.physicsBody?.velocity = CGVector(dx:cos(self.zRotation) * CGFloat(self.carSpeed!),dy:sin(self.zRotation) * CGFloat(self.carSpeed!))
        
        self.vision.removeAll() // clears the vision after being used for next iteration.
        
        self.calculateFitness() // calculate fitness for each of the car nodes
        self.isHidden = false
    }
    
    public init(speed: Double){
        carSpeed = speed
        super.init(texture: nil, color: .yellow, size: CGSize(width: 80, height: 46))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
