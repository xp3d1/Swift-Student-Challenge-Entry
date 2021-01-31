import Foundation
import SwiftUI

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height
            path.addLines( [
                CGPoint(x: width * 0.5, y: height),
                CGPoint(x: width * 0.5, y: height * 0.4),
                CGPoint(x: width * 0.1, y: height * 0.4),
                CGPoint(x: width * 0.5, y: height * 0.1),
                CGPoint(x: width * 0.9, y: height * 0.4),
                CGPoint(x: width * 0.5, y: height * 0.4)
            ])
            path.closeSubpath()
        }
    }
}

struct Semicircle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: 30, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 180.0), clockwise: true)
            path.closeSubpath()
        }
    }
}

struct Circle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: 30, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360), clockwise: true)
            path.closeSubpath()
        }
    }
}




public struct StepsView: View{
    @EnvironmentObject var settings: UserSettings
    @State private var opacity:Double = 0
    @State private var backgroundOpacity:Double = 1
    
    @State private var layerTwo:Bool = false
    @State private var layerThree:Bool = false
    
    @State private var colorChange:Bool = false
    
    @State private var step:Int = 0
    
    public var scene: GameScene
    
    public init(scene: GameScene){
        self.scene = scene
    }
    
    let colours:[Color] = [.red, .green, .yellow, .blue, .orange, .pink]
    let angles:[Double] = [17, -32, 60, -24, -19, -82]
    let offset:[CGPoint] = [CGPoint(x: 13, y: 21), CGPoint(x: -70, y: 62), CGPoint(x: -83, y: -46), CGPoint(x: 130, y: 19), CGPoint(x: 25, y: 123), CGPoint(x: 37, y: -65)]
    public var body: some View{
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.all).opacity(backgroundOpacity)
            HStack{
                Group{
                    if step == 1{
                        ZStack{
                            Rectangle().foregroundColor(.black).opacity(0)
                            ForEach(0 ..< 6) { number in
                                Rectangle().foregroundColor(self.colours[number]).frame(width: 46, height: 80).rotationEffect(.degrees(self.angles[number])).offset(x: self.offset[number].x, y: self.offset[number].y).opacity(self.step == 1 ? 1 : 0)
                            }
                        }
                    }else if step == 2{
                        ZStack{
                            Rectangle().foregroundColor(.black).opacity(0)
                            Group{
                                Arrow()
                                    .stroke(lineWidth: 4).frame(width: layerTwo ? 30 : 10, height:layerTwo ? 70 : 30).rotationEffect(.degrees(180 - 30)).offset(x: -60, y: 0)
                                Arrow()
                                    .stroke(lineWidth: 4).frame(width: layerTwo ? 30 : 10, height:layerTwo ? 70 : 30).rotationEffect(.degrees(180 + 30)).offset(x: 60, y: 0)
                            }.opacity(layerTwo ? 1 : 0)
                            
                            Group{
                                Circle().fill(Color.blue).offset(x: -100, y: -90)
                                Circle().fill(Color.red).offset(x: 100, y: -90)
                            }
                            Group{
                                Semicircle().fill(Color.red).rotationEffect(.degrees(130)).offset(x: 0, y: 80).scaleEffect(layerThree ? 1: 0.5)
                                Semicircle().fill(Color.blue).rotationEffect(.degrees(130+180)).offset(x: 0, y: 80).scaleEffect(layerThree ? 1: 0.5)
                            }.opacity(layerThree ? 1 : 0)
                            
                            
                        }.onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.linear(duration: 1)){
                                    self.layerTwo = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.linear(duration: 1)){
                                    self.layerThree = true
                                }
                            }
                        }
                    }else if step == 3{
                        ZStack{
                            Rectangle().foregroundColor(.black).opacity(0)
                            ForEach(0 ..< 6) { number in
                                Rectangle().foregroundColor(Color.white).colorMultiply(self.colorChange ? Color.red : self.colours[number]).frame(width: 46, height: 80).rotationEffect(.degrees(self.angles[number])).offset(x: self.offset[number].x, y: self.offset[number].y).opacity(self.step == 3 ? 1 : 0)
                            }
                        }.onAppear(){
                            withAnimation(.easeInOut(duration: 5)) {
                               self.colorChange = true
                            }
                        }
                    }else{
                        ZStack{
                            Rectangle().foregroundColor(.black).opacity(0)
                        }
                    }
                }
                
                
                ZStack{
                    Rectangle().foregroundColor(.init(red: 34/255, green: 34/255, blue: 34/255)).cornerRadius(10).padding()
                    VStack{
                        HStack{
                            Text("Steps to evolution").font(.system(size: 35, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.top).padding(.trailing)
                            Spacer()
                        }.padding(.leading).padding(.top).padding(.trailing)
                        Group{
                            HStack{
                                Text("Variation").font(.system(size: 26, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing).padding(.top, 7.5).opacity(step == 1 ? 1 : 0.3)
                                Spacer()
                            }.padding()
                            HStack{
                                Text("The individuals in the population differ from each other to introduce variation.").font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing)
                                    .opacity(step == 1 ? 1 : 0.3)
                                Spacer()
                            }.padding(.leading, 25).padding(.trailing)
                        }.gesture(TapGesture().onEnded{
                            withAnimation(.linear(duration: 1)){
                                self.layerTwo = false
                                self.layerThree = false
                                self.colorChange = false
                                self.step = 1
                            }
                        })
                        
                        Group{
                            HStack{
                                Text("Inheritance").font(.system(size: 26, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing).padding(.top, 3).opacity(step == 2 ? 1 : 0.3)
                                Spacer()
                            }.padding()
                            HStack{
                                Text("Traits and genetic material of the parents are passed along to their offspring.").font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing)
                                    .opacity(step == 2 ? 1 : 0.3)
                                Spacer()
                            }.padding(.leading, 25).padding(.trailing)
                        }.gesture(TapGesture().onEnded{
                            withAnimation(.linear(duration: 1)){
                                self.layerTwo = false
                                self.layerThree = false
                                self.colorChange = false
                                self.step = 2
                            }
                        })
                        
                        Group{
                            HStack{
                                Text("Natural Selection").font(.system(size: 26, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing).padding(.top, 3).opacity(step == 3 ? 1 : 0.3)
                                Spacer()
                            }.padding()
                            HStack{
                                Text("Some individuals perform better than others and can therefore survive and produce more offspring. This in turn results in their genes being more prominent than others.").font(.system(size: 13, weight: .light, design: .default)).multilineTextAlignment(.leading).padding(.leading).padding(.trailing)
                                    .opacity(step == 3 ? 1 : 0.3)
                                Spacer()
                            }.padding(.leading, 25).padding(.trailing)
                        }.gesture(TapGesture().onEnded{
                            withAnimation(.linear(duration: 1)){
                                self.layerTwo = false
                                self.layerThree = false
                                self.colorChange = false
                                self.step = 3
                            }
                        })
                        
                        Spacer()
                        Button(action: {
                            if self.step > 0 && self.step < 3{
                                withAnimation(.linear(duration: 1)){
                                    self.layerTwo = false
                                    self.layerThree = false
                                    self.colorChange = false
                                    self.step += 1
                                }
                            }else if self.step == 3{
                                //transition
                                withAnimation(.linear(duration: 1)) {
                                    self.opacity = 0
                                    self.backgroundOpacity = 1
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.settings.page = 3
                                }
                            }
                            
                        }){
                            Text("Next")
                        }.padding(.bottom, 25)
                    }
                }.transition(.move(edge: .bottom))
            }.opacity(opacity).onAppear{
                self.scene.cameraOffset = 80
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
        }
    }
}

