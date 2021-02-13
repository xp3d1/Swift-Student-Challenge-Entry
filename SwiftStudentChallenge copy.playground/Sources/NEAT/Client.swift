import Foundation
public class Client:Hashable, Codable{
    public var genome:Genome?
    public var score:Double?
    public var species:Species?
    private var calculator:Calculator?
    private var ident:UUID?
    
    enum CodingKeys: String, CodingKey { // used for saving a specific client
        case genome
        case score
        case ident
    }
    
    public init(){ // creates a custom identifier, used for hashing
        ident = UUID()
    }
    
    public func generateCalc(){
        calculator = Calculator(g: genome!)
    }
    
    public func distance(c: Client) -> Double{ // pass through function
        return genome!.distance(g2: c.genome!)
    }
    
    public func mutate(){ // pass through function
        genome!.mutate()
    }
    
    public func calculate(array: [Double]) -> [Double]{
        if calculator == nil{
            generateCalc()
        }
        do {
            return try calculator!.calculate(input: array)
        } catch {
            print("fatal error")
        }
        
        return [Double]()
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ident)
    }
    public static func == (lhs: Client, rhs: Client) -> Bool {
        return lhs.ident == rhs.ident
    }
}
