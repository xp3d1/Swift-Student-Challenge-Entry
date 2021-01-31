import Foundation
public class Species: Hashable, Codable{
    public static func == (lhs: Species, rhs: Species) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public var clients:RHashSet<Client> = RHashSet()
    private var representative:Client?
    public var score:Double = 0
    public var identifier:UUID?
    
    
    public init(representative: Client){
        identifier = UUID()
        self.representative = representative
        self.representative!.species = self
        clients.add(representative)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public func add(client:Client) -> Bool{
        if (representative == nil){
        }
        print()
        if (client.distance(c: representative!) < /*representative!.genome!.neat!.CThreshold*/4){
            client.species = self
            clients.add(client)
            return true
        }
        return false
    }
    
    public func forceAdd(client:Client){
        client.species = self
        clients.add(client)
    }
    
    public func goExtinct(){
        for c in clients.data{
            c.species = nil
        }
    }
    
    public func eval(){
        var cul:Double = 0
        for c in clients.data{
            cul+=c.score!
        }
        score = cul/Double(clients.size())
    }
    
    public func reset(){
        representative = clients.randomElement()!
        for c in clients.data{
            c.species = nil
        }
        clients.clear()
        clients.add(representative!)
        representative!.species = self
        score = 0
    }
    
    public func kill(percent:Double){
        clients.data.sort(by: {$0.score! < $1.score!})
        let st = Int(percent*Double(clients.size()))
        for i in 0..<st{
            clients.get(index: 0).species = nil
            clients.remove(index: 0)
        }
    }
    
    public func breed() -> Genome{
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
}
