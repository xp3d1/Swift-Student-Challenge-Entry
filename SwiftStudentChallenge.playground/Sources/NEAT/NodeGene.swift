
public class NodeGene:Gene, Hashable, Codable{
    public static func == (lhs: NodeGene, rhs: NodeGene) -> Bool {
        return lhs.equals(obj: rhs)
    }
    
    required public init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        x = try values.decode(Double.self, forKey: .x)
        y = try values.decode(Double.self, forKey: .y)
        let i = try values.decode(Int.self, forKey: .inv)
        super.init(innovation: i)
        inv = i
    }

    enum CodingKeys: String, CodingKey {
        case x
        case y
        case inv
    }
    
    public var x:Double = 0, y:Double = 0
    public var inv:Int = 0
    public override init(innovation: Int){
        super.init(innovation: innovation)
        inv = innovation
    }
    public func equals(obj: AnyObject) -> Bool{
        if !(obj is NodeGene){
            return false
        }
        var n = obj as! NodeGene
        return super.innovationNumber == n.innovationNumber
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(super.innovationNumber)
    }
}
