import Foundation
import SwiftUI
import AVFoundation

var audioPlayer: AVAudioPlayer!

public struct MainView: View {
    @EnvironmentObject var settings: UserSettings
    public var scene:GameScene
    public init(scene: GameScene){
        self.scene = scene
    }
    public var body: some View {
        Group {
            if settings.page == 0{
                StartView().environmentObject(settings)
            }else if settings.page == 1{
                IntroductionView(scene: scene).environmentObject(settings)
            }else if settings.page == 2{
                StepsView(scene: scene).environmentObject(settings)
            }else if settings.page == 3{
                ImplementationView(scene: scene).environmentObject(settings)
            }else if settings.page == 4{
                StructureView(scene: scene).environmentObject(settings)
            }else if settings.page == 5{
                LiveEvolutionView(scene: scene).environmentObject(settings)
            }else if settings.page == 6{
                FinalView().environmentObject(settings)
            }
        }.onAppear{
            self.playMusic()
        }
    }
    func playMusic() {
        do {
            guard let filePath = Bundle.main.path(forResource: "ArtOfSilence", ofType: "mp3") else {
                print("ERROR - Failed to retrieve music file Path")
                return
            }
            let fileURL = URL.init(fileURLWithPath: filePath)
            try audioPlayer = AVAudioPlayer.init(contentsOf: fileURL)
        } catch {
            print("ERROR: Failed to retrieve music file URL")
        }

        audioPlayer.volume = 0.0
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        audioPlayer.setVolume(0.1, fadeDuration: 0.75)
    }
}
