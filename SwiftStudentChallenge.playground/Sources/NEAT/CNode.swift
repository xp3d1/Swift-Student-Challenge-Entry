import Foundation
public class CNode:Gene{
    public var x:Double = 0
    public var output:Double = 0
    public var connections:Array<CConnection> = Array()
    
    public init(lx : Double){
        super.init(innovation: 0)
        x = lx
    }
    public func calculate(){ // calculates value of node by multiplying weight by connection and outputs a value from 0 to 1
        var s:Double = 0
        for c in connections{
            if (c.enabled){
                s += c.weight * c.cfrom.output
            }
        }
        output = sigmoidF(x: s)
    }
    private func sigmoidF(x:Double) -> Double{
        return 1/(1 + pow(M_E, -x))
    }
    public func compareTo(n : CNode) -> Int{
        if x > n.x{
            return -1
        }else if x < n.x{
            return 1
        }
        return 0
    }
}
