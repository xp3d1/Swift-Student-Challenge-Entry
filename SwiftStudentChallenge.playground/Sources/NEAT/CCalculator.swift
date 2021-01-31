public class Calculator{
    private var inputNodes:Array<CNode> = Array()
    private var hiddenNodes:Array<CNode> = Array()
    private var outputNodes:Array<CNode> = Array()
    
    public init(g:Genome){
        var nodes:RHashSet<NodeGene> = g.nodes
        var cons:RHashSet<ConnectionGene> = g.connections
        
        var nodeDict:Dictionary<Int, CNode> = Dictionary()
        
        for n in nodes.data{
            var node = CNode(lx: n.x)
            nodeDict[n.innovationNumber!] = node
            if(n.x == 0){
                print(n.innovationNumber!)
            }
            if n.x<=0.1{
                inputNodes.append(node)
            }else if n.x >= 0.9{
                outputNodes.append(node)
            }else{
                hiddenNodes.append(node)
            }
        }
        hiddenNodes.sort(by: { $0.compareTo(n: $1) == -1 })
        
        for c in cons.data{
            var from = c.from!
            var to = c.to!
            var nFrom = nodeDict[from.innovationNumber!]!
            var nTo = nodeDict[to.innovationNumber!]!
            var con = CConnection(from: nFrom, to: nTo)
            con.weight = c.weight
            con.enabled = c.enabled
            
            nTo.connections.append(con)
        }
    }
    
    public func calculate(input: [Double]) throws -> [Double]{
        if (input.count != inputNodes.count){
            throw fatalError()
        }else{
        }
        
        for i in 0..<inputNodes.count{
            inputNodes[i].output = input[i]
        }
        
        for n in hiddenNodes{
            n.calculate()
        }
        var output = [Double]()
        for i in 0..<outputNodes.count{
            outputNodes[i].calculate()
            output.append(outputNodes[i].output)
        }
        return output
    }
}
