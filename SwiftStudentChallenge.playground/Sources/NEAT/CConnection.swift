public class CConnection{
    public var cfrom:CNode = CNode(lx: 0)
    public var cto:CNode = CNode(lx:0)
    
    public var weight:Double = 0.0
    public var enabled = true
    
    public init(from:CNode, to:CNode){
        cfrom = from
        cto = to
    }
}
