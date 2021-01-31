import Foundation
public class Neat:Codable{
    public static var maxNodes:Double = pow(2, 20)
    
    public var allConnections:Dictionary<ConnectionGene, ConnectionGene> = Dictionary()
    public var allNodes:RHashSet<NodeGene> = RHashSet()
    public var inputSize:Int?, outputSize:Int?, maxClients:Int?
    
    public var C1:Double = 1, C2:Double = 1, C3:Double = 1
    
    public var CThreshold:Double = 4
    
    public var scoreThreshold: Double = 300
    
    public var weightShiftMultiplier:Double = 0.3
    public var weightRandomMultiplier:Double = 1
    
    public var probMutateLink:Double = 0.3, probMutateNode:Double = 0.2, probMutateWeightShift:Double = 0.8, probMutateWeightRandom:Double = 0.11, probMutateToggleLink:Double = 0.03
    private var survivorRate:Double = 0.8
    
    public var clients:RHashSet<Client> = RHashSet()
    public var species:RHashSet<Species> = RHashSet()
    public var restored = false
    
    
    enum CodingKeys: String, CodingKey {
        case allConnections
        case allNodes
        case clients
        case species
    }
    
    public init(inputSize:Int, individuals:Int, outputSize:Int){
        reset(inputSize: inputSize, individuals: individuals, outputSize: outputSize)
    }
    required public init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        allConnections = try values.decode(Dictionary<ConnectionGene, ConnectionGene>.self, forKey: .allConnections)
        allNodes = try values.decode(RHashSet<NodeGene>.self, forKey: .allNodes)
        clients = try values.decode(RHashSet<Client>.self, forKey: .clients)
        species = try values.decode(RHashSet<Species>.self, forKey: .species)
        self.inputSize = 5
        self.maxClients = 75
        self.outputSize = 1
    }
    
    public func newEmptyGenome() -> Genome{
        var g = Genome(neat: self)
        for i in 0..<(inputSize!+outputSize!){
            var n = getNode(id: i+1)
            g.nodes.add(n)
        }
        return g
    }
    
    
    public func reset(inputSize:Int, individuals:Int, outputSize:Int){
        self.inputSize = inputSize
        self.outputSize = outputSize
        self.maxClients = individuals
        
        allConnections.removeAll()
        allNodes.clear()
        clients.clear()
        
        for i in 0..<inputSize{
            var n = getNewNode()
            n.x = 0.1
            n.y = Double((i+1)/(inputSize+1))
        }
        for i in 0..<outputSize{
            var n = getNewNode()
            n.x = 0.9
            n.y = Double((i+1)/(outputSize+1))
        }
        for i in 0..<maxClients!{
            var c = Client()
            c.genome = newEmptyGenome()
            c.generateCalc()
            clients.add(c)
        }
    }
    
    public func getClient(index: Int) -> Client{
        return clients.get(index: index)
    }
    
    public func getNewNode() -> NodeGene{
        var n = NodeGene(innovation: allNodes.size() + 1)
        allNodes.add(n)
        return n
    }
    
    public func getNode(id: Int) -> NodeGene{
        if (id <= allNodes.size()){
            return allNodes.get(index: id - 1)
        }
        return getNewNode()
    }
    
    public static func getConnection(con: ConnectionGene) ->ConnectionGene{
        var c = ConnectionGene(from: con.from!, to: con.to!)
        c.innovationNumber = con.innovationNumber
        c.weight = con.weight
        c.enabled = con.enabled
        return c
    }
    public func getConnection(node1: NodeGene, node2:NodeGene) -> ConnectionGene{
        var c = ConnectionGene(from: node1, to: node2)
        if (allConnections[c] != nil){
            c.innovationNumber=allConnections[c]!.innovationNumber
        }else{
            c.innovationNumber = allConnections.count + 1
            allConnections[c] = c
        }
        return c
    }
    
    public func evolve(){
        genSpecies()
        killPop()
        removeExtinctSpecies()
        reproduce()
        mutate()
        for c in clients.data{
            c.generateCalc()
        }
    }
    
    private func genSpecies(){
        
        if restored{
//            for s in species.data{
//                for c in s.clients.data{
//                    c.species = s
//                }
//            }
            for c in clients.data{
                c.genome!.neat = self
            }
            restored = false
        }
        for s in species.data{
            s.reset()
        }
        for c in clients.data{
            if c.species != nil{
                continue
            }
            var found = false
            for s in species.data{
                if s.add(client: c){
                    found = true
                    break
                }
            }
            if !found{
                species.add(Species(representative: c))
            }
        }
        for s in species.data{
            s.eval()
        }
    }
    
    private func killPop(){
        for s in species.data{
            s.kill(percent: 1-survivorRate)
        }
    }
    private func removeExtinctSpecies(){
        for i in (0..<species.size()).reversed(){
            var s = species.get(index: i)
            if s.size() <= 1 && s.score < scoreThreshold{
                s.goExtinct()
                species.remove(index: i)
            }
        }
    }
    private func reproduce(){
        var selector:RSelector<Species> = RSelector()
        for s in species.data{
            selector.add(s, score: s.score)
        }
        for c in clients.data{
            if c.species == nil{
                var s = selector.random()
                c.genome = s?.breed()
                s?.forceAdd(client: c)
            }
        }
    }
    
    private func mutate(){
        for c in clients.data{
            c.mutate()
        }
    }
    public func printSpecies(gen: Int){
        print("################################")
        print("GEN - " + String(gen))
        for s in species.data{
            print("Score: " + String(s.score) + ", Size: " + String(s.size()))
        }
        print("################################")
    }
}
