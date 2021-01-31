import Foundation
public class Client:Hashable, Codable{
    public static func == (lhs: Client, rhs: Client) -> Bool {
        return lhs.ident == rhs.ident
    }

    public var genome:Genome?
    public var score:Double?
    public var species:Species?
    private var calculator:Calculator?
    private var ident:UUID?
    
    enum CodingKeys: String, CodingKey {
        case genome
        case score
        case ident
    }
    
    public init(){
        ident = UUID()
    }
    
    public func generateCalc(){
        calculator = Calculator(g: genome!)
    }
    
    public func distance(c: Client) -> Double{
        return genome!.distance(g2: c.genome!)
    }
    
    public func mutate(){
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
}
