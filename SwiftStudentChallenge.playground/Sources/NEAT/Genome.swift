import Foundation
public class Genome:Hashable, Codable{
    public static func == (lhs: Genome, rhs: Genome) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(connections, forKey: .connections)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(identifier, forKey: .identifier)
    }

    required public init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        connections = try values.decode(RHashSet<ConnectionGene>.self, forKey: .connections)
        nodes = try values.decode(RHashSet<NodeGene>.self, forKey: .nodes)
        identifier = try values.decode(UUID.self, forKey: .identifier)
    }
    
    public var connections:RHashSet<ConnectionGene> = RHashSet()
    public var nodes:RHashSet<NodeGene> = RHashSet()
    public var identifier:UUID?
    public var neat:Neat?
    public var calculator:Calculator?
    
    enum CodingKeys: String, CodingKey {
        case connections
        case nodes
        case identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    public func distance(g2: Genome) -> Double{
        var ng1 = self
        var ng2 = Genome(neat: Neat(inputSize: 0, individuals: 0, outputSize: 0))
        var highestInnovG1 = 0
        var highestInnovG2 = 0
        if ng1.connections.size() != 0{
            highestInnovG1 = ng1.connections.get(index: ng1.connections.size()-1).innovationNumber!
        }
        if g2.connections.size() != 0{
            highestInnovG2 = g2.connections.get(index: g2.connections.size()-1).innovationNumber!
        }
        
        if (highestInnovG1 < highestInnovG2){
            var tempG = g2
            ng2 = ng1
            ng1 = tempG
        }else{
            ng2 = g2
        }
        var indexg1:Int = 0
        var indexg2:Int = 0
        var similar:Int = 0
        var disjoint:Int = 0
        var excess:Int = 0
        var weightDifference:Double = 0
        
        while indexg1 < ng1.connections.size() && indexg2 < ng2.connections.size() {
            var gene1 = ng1.connections.get(index: indexg1)
            var gene2 = ng2.connections.get(index: indexg2)
            
            var in1 = gene1.innovationNumber!
            var in2 = gene2.innovationNumber!
            
            if in1 == in2{
                //similar gene
                similar+=1
                weightDifference += abs(gene1.weight - gene2.weight)
                indexg1+=1
                indexg2+=1
            }else if in1>in2{
                //disjoint gene of b
                disjoint+=1
                indexg2+=1
            }else{
                //disjoint gene of a
                disjoint+=1
                indexg1+=1
            }
        }
        weightDifference /= max(1, Double(similar))
        excess = ng1.connections.size() - indexg1
        var N:Double = Double(max(ng1.connections.size(), ng2.connections.size()))
        if N<20{
            N = 1
        }
        var c1 = neat!.C1
        var c2 = neat!.C2
        var c3 = neat!.C3
        return (Double(disjoint) * c1) / N + (Double(excess) * c2) / N + Double(weightDifference) * c3
    }
    
    public static func crossOver(g1:Genome, g2: Genome) -> Genome{
        var nt = g1.neat
        
        var genome = nt!.newEmptyGenome()
        
        var indexg1:Int = 0
        var indexg2:Int = 0
        
        while indexg1 < g1.connections.size() && indexg2 < g2.connections.size() {
            var gene1 = g1.connections.get(index: indexg1)
            var gene2 = g2.connections.get(index: indexg2)
            
            var in1 = gene1.innovationNumber!
            var in2 = gene2.innovationNumber!
            
            if in1 == in2{
                //similar gene
                if (Bool.random()){
                    genome.connections.add(Neat.getConnection(con: gene1))
                }else{
                    genome.connections.add(Neat.getConnection(con: gene2))
                }
                indexg1+=1
                indexg2+=1
            }else if in1>in2{
                //disjoint gene of b
                indexg2+=1
            }else{
                //disjoint gene of a
                genome.connections.add(Neat.getConnection(con: gene1))
                indexg1+=1
            }
        }
        while (indexg1 < g1.connections.size()){
            var gene1 = g1.connections.get(index: indexg1)
            genome.connections.add(Neat.getConnection(con: gene1))
            indexg1+=1
        }
        for c in genome.connections.data{
            genome.nodes.add(c.from!)
            genome.nodes.add(c.to!)
        }
        return genome
    }
    
    public init(neat:Neat){
        identifier = UUID()
        self.neat = neat
    }
    
    public func mutate(){
        if(neat!.probMutateLink > Double.random(in: 0..<1)){
            mutateLink()
        }
        if(neat!.probMutateNode > Double.random(in: 0..<1)){
            mutateNode()
        }
        if(neat!.probMutateToggleLink > Double.random(in: 0..<1)){
            mutateLinkToggle()
        }
        if(neat!.probMutateWeightShift > Double.random(in: 0..<1)){
            mutateWeightShift()
        }
        if(neat!.probMutateWeightRandom > Double.random(in: 0..<1)){
            mutateWeightRandom()
        }
    }
    private func mutateLink(){
        for i in 0..<100{
            var a = nodes.randomElement()!
            var b = nodes.randomElement()!
            var con = ConnectionGene(from: a, to: b)
            if a.x < b.x{
                con = ConnectionGene(from: a, to: b)
            }else{
                con = ConnectionGene(from: b, to: a)
            }
            
            if connections.contains(con){
                continue
            }
            
            con = neat!.getConnection(node1: con.from!, node2: con.to!)
            con.weight = (Double.random(in: 0..<1) * 2 - 1) * neat!.weightRandomMultiplier
            
            connections.addSorted(con)
            return
        }
    }
    private func mutateNode(){
        var con = connections.randomElement()
        if con == nil{
            return
        }
        var from = con!.from!
        var to = con!.to!
        var mid = neat!.getNewNode()
        mid.x = (from.x + to.x / 2)
        mid.y = (from.y + to.y / 2) // add rand offset
        var con1 = neat!.getConnection(node1: from, node2: mid)
        var con2 = neat!.getConnection(node1: mid, node2: to)
        
        con1.weight = 1
        con2.weight = con!.weight
        con2.enabled = con!.enabled
        
        connections.remove(object: con!)
        connections.add(con1)
        connections.add(con2)
        
        nodes.add(mid)
    }
    private func mutateWeightShift(){
        var con = connections.randomElement()
        if con != nil{
            con!.weight = con!.weight + (Double.random(in: 0..<1) * 2 - 1) * neat!.weightShiftMultiplier
        }
    }
    private func mutateWeightRandom(){
        var con = connections.randomElement()
        if con != nil{
            con!.weight = (Double.random(in: 0..<1) * 2 - 1) * neat!.weightRandomMultiplier
        }
    }
    private func mutateLinkToggle(){
        var con = connections.randomElement()
        if con != nil{
            con!.enabled = !con!.enabled
        }
    }
}
