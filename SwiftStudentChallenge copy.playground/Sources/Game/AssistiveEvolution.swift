import Foundation
import GameKit
import SpriteKit
import SwiftUI

public class AssistiveEvolution: NSObject{
    public var readyAssist = false
    public var assists = 0
    
    
    public func addAssistiveGenome(neat: Neat){ // adds previously trained genome to speed up evolution
        let decoder = PropertyListDecoder()
        do{
            guard let filePath = Bundle.main.path(forResource: "client1", ofType: "plist") else {
                print("ERROR - Failed finding resource for assistive genome")
                return
            }
            let fileURL = URL.init(fileURLWithPath: filePath)
            let retrieveData = try Data(contentsOf: fileURL)
            let decodedClient = try decoder.decode(Client.self, from: retrieveData)
            neat.restored = true
            var selector:RSelector<Client> = RSelector() // chose random genome to replace (with a higher chance depending on the score)
            for c in neat.clients.data{
                selector.add(c, score: c.score!)
            }
            let replace = selector.random()!
            neat.clients.remove(object: replace)
            decodedClient.species = replace.species
            neat.clients.add(decodedClient)
            replace.species!.forceAdd(client: decodedClient)
            
        }catch{
            print("ERROR - Failed retrieving assistive genome.")
        }
    }

    public func primeAssist(){
        self.perform(#selector(allowAssist), with: nil, afterDelay: TimeInterval(60 + Int.random(in: 1..<20)))
    }

    @objc public func allowAssist(){
        readyAssist = true // prepares species for assistance for the next generation
    }

    public func cancelAssist(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(allowAssist), object: nil)
    }
}


