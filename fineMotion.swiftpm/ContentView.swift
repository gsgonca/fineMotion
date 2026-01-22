import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @State private var showTutorial = true
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: screenWidth, height: screenHeight)
        
        scene.scaleMode = .fill
        scene.backgroundColor = .black
        
        return scene
    }
    
    var body: some View {
        Button("Show tutorial") {
            showTutorial = true
        }
        .sheet(isPresented: $showTutorial) {
        } content: {
            parteUm()
                .presentationDetents([.height(280)])
        }
//        .popover(isPresented: $showTutorial) {
//            parteUm()
//        } .frame(width: 200, height: 200)
        
        SpriteView(scene: scene)
                .frame(width: screenWidth, height: screenHeight, alignment: .center)
                .ignoresSafeArea()
                .allowsHitTesting(true)
    }
}
