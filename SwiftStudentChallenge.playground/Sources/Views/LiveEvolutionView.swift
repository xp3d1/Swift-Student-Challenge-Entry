import Foundation
import SwiftUI

struct LiveEvolutionView:View{
    @EnvironmentObject var settings: UserSettings
    @State private var backgroundOpacity:Double = 1
    @State private var opacity:Double = 0
    
    @ObservedObject public var scene:GameScene
    
    public init(scene: GameScene){
        self.scene = scene
    }
    public var body: some View{
        ZStack{
            Color.black
            .edgesIgnoringSafeArea(.all).opacity(backgroundOpacity)
            HStack{
                VStack{
                    ZStack{
                        Rectangle().foregroundColor(.init(red: 34/255, green: 34/255, blue: 34/255)).cornerRadius(10).padding()
                        VStack{
                            HStack{
                                Text("Live Evolution").font(.system(size: 35, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.top).padding(.trailing)
                                Spacer()
                            }.padding(.leading).padding(.top).padding(.trailing)
                            Group{
                                ZStack{
                                    VStack{
                                        HStack{
                                            Text(scene.generationText[scene.generationText.count-1]).font(.system(size: 30, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing)
                                            Spacer()
                                        }.padding(.leading).padding(.trailing)
                                        HStack{
                                            Text(scene.informationText[scene.generationText.count-1]).font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing)
                                            Spacer()
                                        }.padding(.leading).padding(.trailing)
                                    }.padding(.top).padding(.bottom)
                                    
                                }.padding(.leading).padding(.trailing).opacity(scene.opacity)
                                Spacer()
                            }
                            Text("Generation \(scene.gen)").font(.system(size: 22))
                            Button(action: {
                                /*withAnimation(.linear(duration: 1)) {
                                    self.backgroundOpacity = 1
                                }*/
                                //ANIMATE
                                withAnimation(.linear(duration: 1)) {
                                    self.opacity = 0
                                    self.backgroundOpacity = 1
                                }
                                self.scene.scenePaused = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.settings.page = 6
                                }
                            }){
                                Text(scene.buttonText)
                            }.padding(.bottom, 25)
                        }
                    }
                    Spacer()
                }
                Rectangle().foregroundColor(.black).opacity(0)
            }.opacity(opacity)
        }.onAppear{
            withAnimation(.linear(duration: 1)) {
                self.opacity = 1
                self.backgroundOpacity = 0.2
            }
            self.scene.resetComplete()
            self.scene.cameraOffset = -80
        }
    }
}
