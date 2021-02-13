import Foundation
import SwiftUI


extension Animation {
    static func linearDelayed(duration: Double, delay: Double) -> Animation {
        Animation.linear(duration: duration).delay(delay).repeatForever()
    }
}

private func offsetToPoint(size:CGSize, offset:CGPoint) -> CGPoint{
    return CGPoint(x: size.width/2 + offset.x, y: size.height/2 + offset.y)
}

public struct StructureView: View{
    @EnvironmentObject var settings: UserSettings
    @State private var opacity:Double = 0
    @State private var backgroundOpacity:Double = 1
    
    @State private var layerOne:Bool = false
    @State private var connectionsOne:Bool = false
    @State private var layerTwo:Bool = false
    @State private var connectionsTwo:Bool = false
    @State private var layerThree:Bool = false
    @State private var step = 0
    
    public var scene:GameScene
    
    public init(scene:GameScene){
        self.scene = scene
    }
    
    public var body: some View{
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.all).opacity(backgroundOpacity)
            HStack{
                ZStack{
                    Rectangle().foregroundColor(.black).opacity(0)
                    GeometryReader{ g in
                        Group{
                            Path{ path in
                                let s = g.size
                                path.move(to: offsetToPoint(size: s, offset: CGPoint(x: -150, y: -100)))
                                path.addLine(to: offsetToPoint(size: s, offset: CGPoint(x: -30, y: -40)))
                                path.move(to: offsetToPoint(size: s, offset: CGPoint(x: -150, y: 100)))
                                path.addLine(to: offsetToPoint(size: s, offset: CGPoint(x: 60, y: 40)))
                                path.move(to: offsetToPoint(size: s, offset: CGPoint(x: -150, y: 100)))
                                path.addLine(to: offsetToPoint(size: s, offset: CGPoint(x: -30, y: -40)))
                            }.stroke(Color.white, lineWidth: 5).colorMultiply(self.connectionsOne ? Color.blue : Color.init(red: 34/255, green: 34/255, blue: 34/255))
                        }
                        Group{
                            Path{ path in
                                let s = g.size
                                path.move(to: offsetToPoint(size: s, offset: CGPoint(x: -30, y: -40)))
                                path.addLine(to: offsetToPoint(size: s, offset: CGPoint(x: 150, y: 0)))
                                path.move(to: offsetToPoint(size: s, offset: CGPoint(x: 60, y: 40)))
                                path.addLine(to: offsetToPoint(size: s, offset: CGPoint(x: 150, y: -100)))
                                path.move(to: offsetToPoint(size: s, offset: CGPoint(x: 60, y: 40)))
                                path.addLine(to: offsetToPoint(size: s, offset: CGPoint(x: 150, y: 0)))
                                path.move(to: offsetToPoint(size: s, offset: CGPoint(x: -30, y: -40)))
                                path.addLine(to: offsetToPoint(size: s, offset: CGPoint(x: 150, y: 100)))
                                
                            }.stroke(Color.white, lineWidth: 5).colorMultiply(self.connectionsTwo ? Color.blue : Color.init(red: 34/255, green: 34/255, blue: 34/255))
                        }
                    }
                    Group{
                        Circle().fill(Color.white).scaleEffect(0.4).offset(x: -150, y: -100)
                        Circle().fill(Color.white).scaleEffect(0.4).offset(x: -150, y: 100)
                    }.colorMultiply(self.layerOne ? Color.blue : Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    Group{
                        Circle().fill(Color.white).scaleEffect(0.4).offset(x: -30, y: -40)
                        Circle().fill(Color.white).scaleEffect(0.4).offset(x: 60, y: 40)
                    }.colorMultiply(self.layerTwo ? Color.blue : Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    Group{
                        Circle().fill(Color.white).scaleEffect(0.4).offset(x: 150, y: -100)
                        Circle().fill(Color.white).scaleEffect(0.4).offset(x: 150, y: 100)
                        Circle().fill(Color.white).scaleEffect(0.4).offset(x: 150, y: 0)
                    }.colorMultiply(self.layerThree ? Color.blue : Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    
                    
                }
                ZStack{
                    Rectangle().foregroundColor(.init(red: 34/255, green: 34/255, blue: 34/255)).cornerRadius(10).padding()
                    VStack{
                        HStack{
                            Text("Behind the Scenes").font(.system(size: 35, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.top).padding(.trailing)
                            Spacer()
                        }.padding(.leading).padding(.top).padding(.trailing)
                        HStack{
                            Text("It may seem like the AI is super complex. In reality, the AI is actually just a bunch of nodes and connections.\n\nThe input consists of values between 0 and 1, which are then modified by the several weighted connections to produce an output. At the end of every generation, the structure of each individual is changed by random mutations, which helps drive the evolution.\n\nFor this playground, we implemented the genetic algorithm known as NeuroEvolution of Augmenting Topologies, or NEAT, which was developed in 2002.\n\nNow we can create our evolving AI!").font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading).padding()
                            Spacer()
                        }.padding()
                        Spacer()
                        Button(action: {
                            withAnimation(.linear(duration: 1)) {
                                self.opacity = 0
                                self.backgroundOpacity = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.settings.page = 5
                            }
                        }){
                            Text("Next")
                        }.padding(.bottom, 25)
                    }
                }
                
                
            }.opacity(opacity).onAppear{
                self.scene.scenePaused = false
                self.scene.cameraOffset = 80
                withAnimation(.linear(duration: 1)) {
                    self.opacity = 1
                    self.backgroundOpacity = 0.8
                    
                    
                }
                let duration = 0.2
                let delay:Double = 3
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.layerOne = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.layerOne = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.connectionsOne = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.connectionsOne = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.layerTwo = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.layerTwo = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.connectionsTwo = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.connectionsTwo = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.layerThree = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    withAnimation(.linearDelayed(duration: duration, delay: delay)){
                        self.layerThree = false
                    }
                }
            }
        }
    }
}
