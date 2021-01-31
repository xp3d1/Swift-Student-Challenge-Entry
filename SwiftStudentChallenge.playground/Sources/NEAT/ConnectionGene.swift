public class ConnectionGene:Gene, Hashable, Codable{
    
    public static func == (lhs: ConnectionGene, rhs: ConnectionGene) -> Bool {
        lhs.equals(obj: rhs)
    }
    
    required public init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        from = try values.decode(NodeGene.self, forKey: .from)
        to = try values.decode(NodeGene.self, forKey: .to)
        weight = try values.decode(Double.self, forKey: .weight)
        enabled = try values.decode(Bool.self, forKey: .enabled)
        let i = try values.decode(Int.self, forKey: .inv)
        super.init(innovation: i)
        inv = i
    }

    public var inv:Int?
    public var from:NodeGene?
    public var to:NodeGene?
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashCode())
    }
    enum CodingKeys: String, CodingKey {
        case from
        case to
        case weight
        case enabled
        case inv
    }
    public var weight:Double = 0.0
    public var enabled = true
    
    public init(from:NodeGene, to:NodeGene){
        super.init(innovation: 0)
        inv = 0
        self.from = from
        self.to = to
    }
    public func equals(obj: AnyObject) -> Bool{
        if !(obj is ConnectionGene){
            return false
        }
        var c = obj as! ConnectionGene
        return (from!.equals(obj: c.from!) && to!.equals(obj: c.to!))
    }
    public func hashCode() -> Int{
        return from!.innovationNumber! * Int(Neat.maxNodes) + to!.innovationNumber!
    }
}
