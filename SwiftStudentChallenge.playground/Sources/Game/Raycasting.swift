import Foundation
import GameKit
import SpriteKit
import SwiftUI

public class RayCastNode:SKNode{ //ray cast node to find distance to nearest wall
    var dir:Direction?
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func rayCast(scene: SKScene) -> CGFloat{ // raycasts using a ray cast node
        var angle:CGFloat = 0
        var p = self.parent!.convert(self.position, to:scene) // finds the ray cast node in the global scene
        switch self.dir!{
        case Direction.West:
            angle = (self.parent!.zRotation)+(CGFloat.pi/2)
        case Direction.North:
            angle = self.parent!.zRotation
        case Direction.East:
            angle = (self.parent!.zRotation)-(CGFloat.pi/2)
        case Direction.NE:
            angle = (self.parent!.zRotation)-(CGFloat.pi/4)
        case Direction.NW:
            angle = (self.parent!.zRotation)+(CGFloat.pi/4)
        default:
            break
        }
        return rayCastInDirection(point: p, dir: angle, scene: scene)
    }
}
public func rayCastInDirection(point:CGPoint, dir:CGFloat, scene: SKScene) -> CGFloat{ // raycasts in direction
    var dist:CGFloat = 0
    let maxDist = 800
    let accuracy:CGFloat = 0.5
    
    for _ in 0..<maxDist{
        let x:CGFloat = point.x + ((cos(dir) * accuracy) * CGFloat(dist)) // moves step in each axis
        let y:CGFloat = point.y + ((sin(dir) * accuracy) * CGFloat(dist))
        if let body = scene.physicsWorld.body(at: CGPoint(x: x, y: y)){
            if (body.categoryBitMask == CollisionCategory.wall){
                return dist // if collides return distance
            }
            dist += 1
        }else{
            dist += 1
        }
    }
    return CGFloat(maxDist)
}
