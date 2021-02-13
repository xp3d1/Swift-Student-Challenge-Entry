
public class RHashSet<T>:Hashable, Codable where T : Hashable & Codable{ // a set and array combined
    

    public var set = Set<T>()
    public var data = Array<T>()
    
    public func contains(_ obj: T) -> Bool {
        return set.contains(obj)
    }
    public func randomElement() -> T?{
        return data.randomElement()
    }
    public func size() -> Int{
        return data.count
    }
    
    public func add(_ obj:T){ // if set does not contain element already, add it.
        if (!set.contains(obj)){
            set.insert(obj)
            data.append(obj)
        }
    }
    public func clear(){
        set.removeAll()
        data.removeAll()
    }
    
    public func get(index: Int) -> T{
        return data[index]
    }
    
    public func remove(index: Int){
        if index<0 || index >= size(){
            return
        }
        set.remove(data[index])
        data.remove(at: index)
    }
    
    public func remove(object: T){
        set.remove(object)
        data.remove(at: data.firstIndex(of: object)!) // as long as object is in data, there will only be one as we checked the hash
    }
    
    public func addSorted(_ obj:T){ // add based on innovation number - MUST ONLY BE USED ON GENES OR CLASSES INHERITED FROM GENES
        for i in 0..<size(){
            var gene = data[i] as! Gene
            var innov:Int = gene.innovationNumber!
            if ((obj as! Gene).innovationNumber! < innov){
                data.insert(obj, at: i)
                set.insert(obj)
                return
            }
        }
        data.append(obj)
        set.insert(obj)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
    public static func == (lhs: RHashSet<T>, rhs: RHashSet<T>) -> Bool {
        return lhs.data == rhs.data
    }
    
    required public init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        set = try values.decode(Set<T>.self, forKey: .set)
        data = try values.decode(Array<T>.self, forKey: .data)
    }
    
    public init(){
        
    }
    
    enum CodingKeys: String, CodingKey {
        case set
        case data
    }
}

