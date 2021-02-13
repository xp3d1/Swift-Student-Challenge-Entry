import Foundation
import SwiftUI

public struct FinalView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var opacity:Double = 0
    public init() {}
    public var body: some View {
        ZStack{
            Color.black
            .edgesIgnoringSafeArea(.all)
            VStack{
                Text(".evolution").font(.system(size: 70, weight: .thin, design: .default))
                Text("Thank you for watching! Now you have learned the basics of genetic algorithms.").font(.system(size: 19, weight: .light, design: .default))
            }.opacity(opacity)
        }.onAppear{
            withAnimation(.linear(duration: 1)) {
                self.opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.linear(duration: 1)) {
                    self.opacity = 0
                }
            }
        }
            
    }
}
