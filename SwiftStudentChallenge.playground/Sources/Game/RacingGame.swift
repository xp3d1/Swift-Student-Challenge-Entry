import Foundation
import GameKit
import SpriteKit
import SwiftUI

struct CollisionCategory { //different collision categories for identifying the bodies in a collision
    static let car : UInt32 = 0x1 << 1
    static let wall : UInt32 = 0x1 << 2
    static let checkpoint : UInt32 = 0x1 << 3
}

enum Direction{
    case North
    case South
    case East
    case West
    case NE
    case NW
}
var checkpointsCount = 14 //number of checkpoints


public class Checkpoint:SKSpriteNode{
    var num:Int = 0
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject{
    let cam = SKCameraNode()
    var neat:Neat?
    var checkReached = 0
    public var assister = AssistiveEvolution() // helps in assisting the evolution
    public var evolutionStep = 0
    public var scenePaused = true
    public var shouldAssist = false
    public var cameraOffset = 0
    private var cars:[Car] = []
    @Published public var gen = 1
    @Published var generationText:[String] = ["Training"]
    @Published var informationText:[String] = ["Please wait"]
    @Published var opacity:Double = 1
    @Published var buttonText:String = "Skip"
    @Published var neatSpecies:Int = 1
    @Published var generationOpacity:Double = 1
    
    
    public func didBegin(_ contact: SKPhysicsContact) { // on contact between two bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask { // first body is the body with the lower category bit mask
          firstBody = contact.bodyA
          secondBody = contact.bodyB
        } else {
          firstBody = contact.bodyB
          secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & CollisionCategory.car != 0) &&
            (secondBody.categoryBitMask & CollisionCategory.wall != 0)){
            let car = firstBody.node as! Car
            car.alive = false
        }
        if ((firstBody.categoryBitMask & CollisionCategory.car != 0) &&
            (secondBody.categoryBitMask & CollisionCategory.checkpoint != 0)){
            let car = firstBody.node as! Car
            let checkpoint = secondBody.node as! Checkpoint
            car.checkpoint = checkpoint.num
            if checkpoint.num > checkReached{ // new checkpoint reached and kill timer should be increased
                cancelKillAll()
                primeKillAll()
                checkReached = checkpoint.num
            }
            if checkReached > 6{ // cancel assist
                assister.cancelAssist()
            }
            
        }
    }
    
    override public func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        setUpNeat(ind: 30)
        initialReset()
        reset()
    }
    
    public func resetComplete(){
        cancelKillAll()
        setUpNeat(ind: 75)
        gen = 1
        checkReached = 0
        initialReset()
        reset()
        shouldAssist = true
        assister.primeAssist()
    }
    
    
    
    
    
    public func fadeOut(){
        withAnimation(.linear(duration: 0.3)) {
            opacity = 0
        }
    }
    
    public func fadeIn(){
        withAnimation(.linear(duration: 0.3)) {
            opacity = 1
        }
    }
    
    public func updateEvolve(){ // updates side panel
        if shouldAssist{
            if gen == 1 && evolutionStep == 0{
                fadeOut()
                generationText[0] = "Generation 1"
                informationText[0] = "The AI has just been born and is starting to evolve! It is not very good yet, however that will soon change..."
                fadeIn()
                evolutionStep += 1
            }else if checkReached == 3 && evolutionStep == 1{
                fadeOut()
                generationText.append("Generation \(gen)")
                informationText.append("The AI has evolved to reach the third checkpoint! Will it reach the end of the course?")
                fadeIn()
                evolutionStep += 1
            }else if checkReached == 7 && evolutionStep == 2{
                fadeOut()
                generationText.append("Generation \(gen)")
                informationText.append("Now the AI has reached the middle of the course! One step closer to the end.")
                fadeIn()
                evolutionStep += 1
            }else if checkReached == 14 && evolutionStep == 3{
                fadeOut()
                generationText.append("Generation \(gen)")
                informationText.append("The first AI has reached the finish line! Click next, or keep watching to see more individuals reach the end.")
                buttonText = "Next"
                fadeIn()
                evolutionStep += 1
            }
        }
    }
    
    private func incrementGeneration(){
        gen += 1
    }
    
    @objc public func evolveAndCont(){ // evolves and continues
        for case let carNode as Car in self.scene!.children{
            carNode.aiClient!.score = carNode.fitness // assigns the score to each of the AI clients
        }
        neatSpecies = neat!.species.data.count
        updateEvolve() // updates side panel
        neat!.evolve() // evolves all the clients
        neat!.printSpecies(gen: gen)
        incrementGeneration()
        if (shouldAssist && assister.readyAssist && checkReached < 3 && assister.assists < 2){ // if evolution is occuring too slow, add assistive genome to speed up the process
            assister.assists += 1
            assister.addAssistiveGenome(neat: neat!)
        }
        self.reset() // resets ready for next generation
    }
    public func setUpNeat(ind: Int){
        neat = Neat(inputSize: 5, individuals: ind, outputSize: 1)
    }
    
    public func primeKillAll(){
        self.perform(#selector(evolveAndCont), with: nil, afterDelay: 5) // kills all clients if no new checkpoints are reached in 5 seconds.
    }
    
    
    
    public func initialReset(){
        scene?.backgroundColor = .black
        self.camera = cam
        
        for i in 0..<checkpointsCount{ //create physics body for each checkpoint.
            print("gonnafail")
            let c = childNode(withName: "//" + String(i + 1)) as! Checkpoint
            print("toldya")
            c.num = i + 1
            c.physicsBody = SKPhysicsBody(rectangleOf: c.size)
            
            if let physics = c.physicsBody{
                physics.affectedByGravity = false
                physics.isDynamic = true
                physics.categoryBitMask = CollisionCategory.checkpoint
                physics.contactTestBitMask = CollisionCategory.car
                physics.collisionBitMask = 0
                physics.allowsRotation = true
                physics.mass = 0
                physics.linearDamping = 0
                physics.angularDamping = 0
                
            }
        }
        
        enumerateChildNodes(withName: "wall") { (node:SKNode, nil) in // creates physics body for each wall.
            let n = node as! SKSpriteNode
            node.physicsBody = SKPhysicsBody(rectangleOf: n.size)
            if let physics = n.physicsBody{
                    physics.affectedByGravity = false
                    physics.isDynamic = true
                    physics.categoryBitMask = CollisionCategory.wall
                    physics.contactTestBitMask = CollisionCategory.car
                    physics.collisionBitMask = 0
                    physics.allowsRotation = true
                    physics.mass = 0
                    physics.linearDamping = 0
                    physics.angularDamping = 0
            }
        }
    }
    
    public func reset(){ // resets after each generation
        checkReached = 0
        primeKillAll()
        
        for case let carNode as Car in scene!.children{ // destroys all previous car nodes
            carNode.removeFromParent()
        }
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        if let physics = self.physicsBody{ // creates physics body for frame
            physics.affectedByGravity = false
            physics.isDynamic = false
            physics.categoryBitMask = 0
            physics.contactTestBitMask = 0
            physics.collisionBitMask = 0
            physics.allowsRotation = false
            physics.mass = 0
            physics.linearDamping = 0
            physics.angularDamping = 0
        }
        
        
        for c in neat!.clients.data{ //creates a car for each client
            let car = Car(speed: Double(500))
            car.alive = true
            car.aiClient = c
            car.alpha = 1
            car.zRotation = CGFloat(Float.pi/2)
            car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
                    
            if let physics = car.physicsBody{
                physics.affectedByGravity = false
                physics.isDynamic = true
                physics.categoryBitMask = CollisionCategory.car
                physics.contactTestBitMask = CollisionCategory.wall
                physics.collisionBitMask = 0
                physics.allowsRotation = true
                physics.mass = 0
                physics.linearDamping = 0
                physics.angularDamping = 0
                        
            }
            scene?.addChild(car)
            for i in 0..<5{ // create ray cast nodes for vision
                let n = RayCastNode()
                switch i{
                    case 0:
                        n.dir = Direction.West
                        n.position = CGPoint(x: 0, y: -23)
                    case 1:
                        n.dir = Direction.North
                        n.position = CGPoint(x: 40, y: 0)
                    case 2:
                        n.dir = Direction.East
                        n.position = CGPoint(x: 0, y: 23)
                    case 3:
                        n.dir = Direction.NE
                        n.position = CGPoint(x: 40, y: 23)
                    case 4:
                        n.dir = Direction.NW
                        n.position = CGPoint(x: 40, y: -23)
                    default:
                        break
                }
                    car.addChild(n)
            }
        }
        
        cam.position = CGPoint(x: cam.position.x - 90, y: cam.position.y)
    }
    
    @objc static public override var supportsSecureCoding: Bool {
        get {
            return true
        }
    }
    
    public func anyAlive() -> Bool{ // returns true if there are cars alive
        for case let carNode as Car in scene!.children {
            if !carNode.alive{
                continue
            }else{
                return true
            }
        }
        return false
    }
    
    private func cancelKillAll(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(evolveAndCont), object: nil)
    }
    
    
    
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if scenePaused{ // if the scene is paused
            cancelKillAll()
            for case let carNode as Car in scene!.children{
                if (carNode.physicsBody?.velocity != CGVector(dx: 0, dy: 0)){
                    carNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            }
            return
        }
        
        if !anyAlive(){ // if all cars have died, end the generation
            cancelKillAll()
            evolveAndCont()
            primeKillAll()
        }
        updateEvolve() // update side panel
        var sorted:[Car] = []
        
        for case let carNode as Car in scene!.children {
            if !carNode.alive{
                if (carNode.physicsBody?.velocity != CGVector(dx: 0, dy: 0)){ //freezes dead cars
                    carNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
                continue
            }
            carNode.update(scene: self)
            sorted.append(carNode)
        }
        sorted.sort(by: {$0.fitness > $1.fitness})
        cam.position = CGPoint(x: sorted[0].position.x + CGFloat(cameraOffset), y: sorted[0].position.y) //
    }
    
    
}

extension CGPoint {
    // finds the distance between two points
    
    func distance(point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy);
    }
}
