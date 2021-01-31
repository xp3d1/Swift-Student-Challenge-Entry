import Foundation
import GameKit
import SpriteKit
import Carbon
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

public class RayCastNode:SKNode{ //ray cast node to find distance to nearest wall
    var dir:Direction?
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
var checkpointsCount = 14 //number of checkpoints
public class Car:SKSpriteNode{
    var carSpeed:Double?
    var alive:Bool = true
    var vision:[Double] = []
    var aiClient:Client?
    var fitness:Double = 0
    var checkpoint:Int = 0
    
    func calculateFitness(){
        fitness = Double(checkpoint) * 50
        if (checkpoint != checkpointsCount){
            let check = scene!.childNode(withName: "//" + String(checkpoint + 1)) as! Checkpoint
            fitness += Double(3000/position.distance(point: check.position))
        }else{
            fitness += 1000
            alive = false
        }
    }
    
    init(speed: Double){
        carSpeed = speed
        super.init(texture: nil, color: .yellow, size: CGSize(width: 80, height: 46))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

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
    var readyAssist = false
    var assists = 0
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
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(evolveAndCont), object: nil)
                primeKillAll()
                checkReached = checkpoint.num
            }
            if checkReached > 6{ // cancel assist
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(allowAssist), object: nil)
            }
            
        }
    }
    
    override public func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        setUpNeat(ind: 30)
        reset()
    }
    
    public func resetComplete(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(evolveAndCont), object: nil)
        setUpNeat(ind: 75)
        gen = 1
        checkReached = 0
        reset()
        shouldAssist = true
        primeAssist()
    }
    
    public func addAssistiveGenome(){ // adds previously trained genome to speed up evolution
        let decoder = PropertyListDecoder()
        do{
            guard let filePath = Bundle.main.path(forResource: "client1", ofType: "plist") else {
                print("ERROR - Failed finding resource for assistive genome")
                return
            }
            let fileURL = URL.init(fileURLWithPath: filePath)
            let retrieveData = try Data(contentsOf: fileURL)
            let cl = try decoder.decode(Client.self, from: retrieveData)
            neat!.restored = true
            var selector:RSelector<Client> = RSelector()
            for c in neat!.clients.data{
                selector.add(c, score: c.score!)
            }
            let replace = selector.random()!
            neat!.clients.remove(object: replace)
            cl.species = replace.species
            neat!.clients.add(cl)
            replace.species!.forceAdd(client: cl)
            
        }catch{
            print("ERROR - Failed retrieving assistive genome.")
        }
    }
    
    public var st = 0
    
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
    
    public func updateEvolve(){
        if shouldAssist{
            if gen == 1 && st == 0{
                fadeOut()
                generationText[0] = "Generation 1"
                informationText[0] = "The AI has just been born and is starting to evolve! It is not very good yet though, however that will soon change..."
                fadeIn()
                st += 1
            }else if checkReached == 3 && st == 1{
                fadeOut()
                generationText.append("Generation \(gen)")
                informationText.append("The AI has evolved to reach the third checkpoint! Will it reach the end of the course?")
                fadeIn()
                st += 1
            }else if checkReached == 7 && st == 2{
                fadeOut()
                generationText.append("Generation \(gen)")
                informationText.append("Now the AI has reached the middle of the course! One step closer to the end.")
                fadeIn()
                st += 1
            }else if checkReached == 14 && st == 3{
                fadeOut()
                generationText.append("Generation \(gen)")
                informationText.append("The first AI has reached the finish line! Click next, or keep watching to see more individuals reach the end.")
                buttonText = "Next"
                fadeIn()
                st += 1
            }
        }
    }
    
    private func incrementGeneration(){
        gen += 1
    }
    
    @objc public func evolveAndCont(){
        for case let carNode as Car in self.scene!.children{
            carNode.aiClient!.score = carNode.fitness
        }
        neatSpecies = neat!.species.data.count
        updateEvolve()
        neat!.evolve()
        neat!.printSpecies(gen: gen)
        incrementGeneration()
        if (shouldAssist && readyAssist && checkReached < 3 && assists < 2){
            assists += 1
            addAssistiveGenome()
        }
        self.reset()
    }
    public func setUpNeat(ind: Int){
        neat = Neat(inputSize: 5, individuals: ind, outputSize: 1)
    }
    
    public func primeKillAll(){
        self.perform(#selector(evolveAndCont), with: nil, afterDelay: 5)
    }
    
    public func primeAssist(){
        self.perform(#selector(allowAssist), with: nil, afterDelay: TimeInterval(80 + Int.random(in: 1..<20)))
    }
    
    @objc public func allowAssist(){
        readyAssist = true
    }
    
    public func reset(){
        checkReached = 0
        if (gen != 80){
            primeKillAll()
        }
        
        for case let carNode as Car in scene!.children{
            carNode.removeFromParent()
        }
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
                borderBody.friction = 0
                self.physicsBody = borderBody
                if let physics = self.physicsBody{
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
                scene?.backgroundColor = .black

                
                self.camera = cam
                for i in 0..<checkpointsCount{
                    let c = childNode(withName: "//" + String(i + 1)) as! Checkpoint
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
        for c in neat!.clients.data{
                    let car = Car(speed: Double(500))
            car.alive = true
            car.aiClient = c
                    //carNode!.isHidden = !(fitness == 10)
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
                    for i in 0..<5{
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
                
                enumerateChildNodes(withName: "wall") { (node:SKNode, nil) in
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
    
    @objc static public override var supportsSecureCoding: Bool {
        get {
            return true
        }
    }
    
    public func anyAlive() -> Bool{
        for case let carNode as Car in scene!.children {
            if !carNode.alive{
                continue
            }else{
                return true
            }
        }
        return false
    }
    
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if scenePaused{
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(evolveAndCont), object: nil)
            return
        }
        
        if !anyAlive(){
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(evolveAndCont), object: nil)
            evolveAndCont()
            primeKillAll()
        }
        updateEvolve()
        var s:[Car] = []
        for case let carNode as Car in scene!.children {
            if !carNode.alive{
                if (carNode.physicsBody?.velocity != CGVector(dx: 0, dy: 0)){
                    carNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
                continue
            }
            for case let rTrace as RayCastNode in carNode.children{
                            carNode.vision.append(Double(rayCast(rcnode: rTrace)))
            }
            carNode.zRotation += CGFloat(((carNode.aiClient!.calculate(array: carNode.vision)[0])*0.2)-0.1)
            carNode.physicsBody?.velocity = CGVector(dx:cos(carNode.zRotation) * CGFloat(carNode.carSpeed!),dy:sin(carNode.zRotation) * CGFloat(carNode.carSpeed!))
            cam.position = CGPoint(x: carNode.position.x + CGFloat(cameraOffset), y: carNode.position.y)
            carNode.vision.removeAll()
            
            carNode.calculateFitness()
            s.append(carNode)
            carNode.isHidden = true
        }
        s.sort(by: {$0.fitness > $1.fitness})
        var i = 0
        for car in s{
            if i<10{
                car.isHidden = false
            }
            
        }
    }
    
    public func rayCast(rcnode: RayCastNode) -> CGFloat{
        var angle:CGFloat = 0
        var p = rcnode.parent!.convert(rcnode.position, to:scene!)
        switch rcnode.dir!{
        case Direction.West:
            angle = (rcnode.parent!.zRotation)+(CGFloat.pi/2)
        case Direction.North:
            angle = rcnode.parent!.zRotation
        case Direction.East:
            angle = (rcnode.parent!.zRotation)-(CGFloat.pi/2)
        case Direction.NE:
            angle = (rcnode.parent!.zRotation)-(CGFloat.pi/4)
        case Direction.NW:
            angle = (rcnode.parent!.zRotation)+(CGFloat.pi/4)
        default:
            break
        }
        return rayCastInDirection(point: p, dir: angle)
    }
    
    public func rayCastInDirection(point:CGPoint, dir:CGFloat) -> CGFloat{
        var dist:CGFloat = 0
        let maxDist = 800
        let accuracy:CGFloat = 0.5
        
        for _ in 0..<maxDist{
            let x:CGFloat = point.x + ((cos(dir) * accuracy) * CGFloat(dist))
            let y:CGFloat = point.y + ((sin(dir) * accuracy) * CGFloat(dist))
            if let body = physicsWorld.body(at: CGPoint(x: x, y: y)){
                if (body.categoryBitMask == CollisionCategory.wall){
                    return dist
                }
                dist += 1
            }else{
                dist += 1
            }
        }
        return CGFloat(maxDist)
    }
}

extension CGPoint {

    /**
    Calculates a distance to the given point.

    :param: point - the point to calculate a distance to

    :returns: distance between current and the given points
    */
    func distance(point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy);
    }
}
