import Foundation
public class Species: Hashable, Codable{
    

    public var clients:RHashSet<Client> = RHashSet()
    private var representative:Client?
    public var score:Double = 0
    public var identifier:UUID?
    
    public func add(client:Client) -> Bool{ // adds client only if the distance to the representative is smaller than the species threshold
        if (representative == nil){
        }
        print()
        if (client.distance(c: representative!) < representative!.genome!.neat!.CThreshold){
            client.species = self
            clients.add(client)
            return true
        }
        return false
    }
    
    public func forceAdd(client:Client){ // force add without checking distance for offspring
        client.species = self
        clients.add(client)
    }
    
    public func goExtinct(){
        for c in clients.data{
            c.species = nil
        }
    }
    
    public func eval(){ // calculates the average score of the species
        var cul:Double = 0
        for c in clients.data{
            cul+=c.score!
        }
        score = cul/Double(clients.size())
    }
    
    public func reset(){ // removes all clients in the species, but keeps the representative to add clients with similar genes
        representative = clients.randomElement()!
        for c in clients.data{
            c.species = nil
        }
        clients.clear()
        clients.add(representative!)
        representative!.species = self
        score = 0
    }
    
    public func kill(percent:Double){ // kills part of the population based on score
        clients.data.sort(by: {$0.score! < $1.score!})
        let st = Int(percent*Double(clients.size()))
        for i in 0..<st{
            clients.get(index: 0).species = nil
            clients.remove(index: 0)
        }
    }
    
    public func breed() -> Genome{ // breeds random clients in the species
        var c1 = clients.randomElement()!
        var c2 = clients.randomElement()!
        if c1.score!>c2.score!{
            return Genome.crossOver(g1: c1.genome!, g2: c2.genome!)
        }
        return Genome.crossOver(g1: c2.genome!, g2: c1.genome!)
    }
    
    public func size() -> Int{
        return clients.size()
    }
    
    public static func == (lhs: Species, rhs: Species) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    public init(representative: Client){
        identifier = UUID()
        self.representative = representative
        self.representative!.species = self
        clients.add(representative)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
