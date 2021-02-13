import Foundation
import SwiftUI

public struct ImplementationView: View{
    @EnvironmentObject var settings: UserSettings
    @State private var opacity:Double = 0
    @State private var backgroundOpacity:Double = 1
    private var point = CGPoint(x: 700, y: 100)
    @State private var time:[Double] = [3, 1, 4, 1.7, 2, 5]
    @State private var offset:[CGFloat] = [-150, -90, -30, 30, 90, 150]
    @State private var corners:[CGPoint] = [CGPoint(x: -23, y: 0), CGPoint(x: -23, y: -40), CGPoint(x: 0, y: -40), CGPoint(x: 23, y: -40), CGPoint(x: 23, y: 0)]
    @State private var length:[CGPoint] = [CGPoint(x: -100, y: 0), CGPoint(x: -80, y: -80), CGPoint(x: 0, y: -100), CGPoint(x: 80, y: -80), CGPoint(x: 100, y: 0)]
    @State private var step = 0 {
        didSet{
            time = [3, 1, 4, 1.7, 2, 5]
        }
    }
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
                    Rectangle().foregroundColor(.init(red: 34/255, green: 34/255, blue: 34/255)).cornerRadius(10).padding()
                    VStack{
                        HStack{
                            Text("Implementation").font(.system(size: 35, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.top).padding(.trailing)
                            Spacer()
                        }.padding(.leading).padding(.top).padding(.trailing)
                        HStack{
                            Text("We are almost ready to train the AI, however there are still a few things missing.").font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing).padding(.top)
                            Spacer()
                        }.padding(.leading).padding(.top).padding(.trailing)
                        Group{
                            HStack{
                                Text("Fitness").font(.system(size: 26, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing).padding(.top, 3).opacity(step == 1 ? 1 : 0.3)
                                Spacer()
                            }.padding()
                            HStack{
                                Group{
                                    Text("The fitness function enables us to identify how \"good\" a certain individual is, and is crucial in making natural selection and evolution work. In our example, the fitness function would be how much of the racecourse a car completes.").font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading)
                                }.padding(.leading).padding(.trailing)
                                .opacity(step == 1 ? 1 : 0.3)
                                
                                
                                Spacer()
                            }.padding(.leading, 25).padding(.trailing)
                        }.gesture(TapGesture().onEnded{
                            withAnimation(.linear(duration: 1)){
                                self.step = 1
                            }
                        })
                        Group{
                            HStack{
                                Text("Inputs and Outputs").font(.system(size: 26, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing).padding(.top, 3).opacity(step == 2 ? 1 : 0.3)
                                Spacer()
                            }.padding()
                            HStack{
                                Text("Each of the cars are given five distances to the nearest wall in the forward facing directions. The cars will then output a steering direction relative to themselves.").font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing)
                                    .opacity(step == 2 ? 1 : 0.3)
                                Spacer()
                            }.padding(.leading, 25).padding(.trailing)
                        }.gesture(TapGesture().onEnded{
                            withAnimation(.linear(duration: 1)){
                                self.step = 2
                            }
                        })
                        Spacer()
                        Button(action: {
                            if self.step > 0 && self.step < 2{
                                withAnimation(.linear(duration: 1)){
                                    self.step += 1
                                }
                            }else if self.step == 2{
                                withAnimation(.linear(duration: 1)) {
                                    self.opacity = 0
                                    self.backgroundOpacity = 1
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.settings.page = 4
                                }
                            }
                        }){
                            Text("Next")
                        }.padding(.bottom, 25)
                    }
                    }.opacity(opacity).onAppear{
                        self.scene.cameraOffset = -80
                withAnimation(.linear(duration: 1)) {
                    self.opacity = 1
                    self.backgroundOpacity = 0.8
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.linear(duration: 1)){
                            self.step = 1
                        }
                    }
                }
                HStack{
                    Group{
                        if step == 1{
                            ZStack{
                                Rectangle().foregroundColor(.black).opacity(0)
                                Group{
                                    ForEach(0 ..< 6) { number in
                                        Rectangle().foregroundColor(Color.white).colorMultiply(self.time[number] == 0 ? Color.green : Color.red).frame(width: 46, height: 80).offset(x: self.offset[number], y: self.time[number] == 0 ? 170 : -170)
                                    }
                                }
                                
                            }.onAppear{
                                for (i, time) in self.time.enumerated(){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation(.easeInOut(duration: time)){
                                            self.time[i] = 0
                                        }
                                    }
                                }
                            }
                        }else if step == 2{
                            ZStack{
                                Rectangle().foregroundColor(.black).opacity(0)
                                Rectangle().foregroundColor(Color.red).frame(width: 46, height: 80)
                                GeometryReader{ g in
                                    Group{
                                        ForEach(0..<5) { number in
                                            Path{ path in
                                                path.move(to: CGPoint(x: g.size.width/2 + self.corners[number].x, y: g.size.height/2 + self.corners[number].y))
                                                path.addLine(to: CGPoint(x: g.size.width/2 + self.corners[number].x + self.length[number].x, y: g.size.height/2 + self.corners[number].y + self.length[number].y))
                                            }.stroke(Color.blue, lineWidth: 5)
                                        }
                                    }
                                }
                            }.onAppear{
                                
                            }
                        }else{
                            ZStack{
                               Rectangle().foregroundColor(.black).opacity(0)
                            }
                        }
                    }
                }
                
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
