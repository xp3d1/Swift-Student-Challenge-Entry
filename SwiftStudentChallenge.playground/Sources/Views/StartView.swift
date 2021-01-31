import Foundation
import SwiftUI

public struct StartView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var opacity:Double = 0
    public init() {}
    public var body: some View {
        ZStack{
            Color.black
            .edgesIgnoringSafeArea(.all)
            VStack{
                Text(".evolution").font(.system(size: 70, weight: .thin, design: .default))
                Text("Click anywhere to start").font(.system(size: 19, weight: .light, design: .default))
            }.opacity(opacity)
        }.onAppear{
            withAnimation(.linear(duration: 1)) {
                self.opacity = 1
            }
        }.gesture(TapGesture().onEnded{
            withAnimation(.linear(duration: 1)) {
                self.opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.settings.page = 1
            }
        })
            
    }
}
