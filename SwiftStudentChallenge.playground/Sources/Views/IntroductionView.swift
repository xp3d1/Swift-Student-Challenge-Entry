import Foundation
import SwiftUI

public struct IntroductionView: View{
    @EnvironmentObject var settings: UserSettings
    @State private var opacity:Double = 0
    @State private var backgroundOpacity:Double = 1
    public var scene:GameScene
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public var body: some View{
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.all).opacity(backgroundOpacity)
            HStack{
                ZStack{
                    Rectangle().foregroundColor(.init(red: 34/255, green: 34/255, blue: 34/255)).cornerRadius(10).padding()
                    VStack{
                        HStack{
                            Text("Introduction").font(.system(size: 35, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.top).padding(.trailing)
                            Spacer()
                        }.padding(.leading).padding(.top).padding(.trailing)
                        HStack{
                            Text("In this Swift playground, we are going to learn about genetic algorithms and its application.\n\nTo do this, we are going to create an AI that will learn to complete a race course.\n\nGenetic algorithms actually follow similar patterns to real life evolution. There is a population made up of individuals, who are split into different species. Over time, the populations reproduce and mutate to produce better future generations through natural selection.").font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading).padding()
                            Spacer()
                        }.padding()
                        Spacer()
                        Button(action: {
                            withAnimation(.linear(duration: 1)) {
                                self.opacity = 0
                                self.backgroundOpacity = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.settings.page = 2
                            }
                        }){
                            Text("Next")
                        }.padding(.bottom, 25)
                    }
                }
                
                Rectangle().foregroundColor(.black).opacity(0)
            }.opacity(opacity).onAppear{
                self.scene.scenePaused = false
                self.scene.cameraOffset = -80
            withAnimation(.linear(duration: 1)) {
                self.opacity = 1
                self.backgroundOpacity = 0.8
                }
                
            }
        }
    }
}
