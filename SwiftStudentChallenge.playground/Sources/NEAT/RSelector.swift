
public class RSelector<T>{
    // This class picks a random element from an array, but is weighted based on the score of an element
    // e.g. a higher scoring element will have a higher chance of being chosen that a low scoring element
    private var objects:Array<T> = Array()
    private var scores:Array<Double> = Array()
    
    private var totalS:Double = 0
    
    public func add(_ element: T, score:Double){
        objects.append(element)
        scores.append(score)
        totalS += score
    }
    public func random() -> T?{
        var v = Double.random(in: 0...1) * totalS
        var cul:Double = 0
        
        for (i, e) in objects.enumerated(){
            cul += scores[i]
            if (cul >= v){
                return e
            }
        }
        return nil
    }
    public func clear(){
        objects.removeAll()
        scores.removeAll()
        totalS = 0
    }
}

