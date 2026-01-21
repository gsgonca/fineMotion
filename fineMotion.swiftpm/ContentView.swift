import SwiftUI
import SpriteKit

struct ContentView: View {
    
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
        SpriteView(scene: scene)
                .frame(width: screenWidth, height: screenHeight, alignment: .center)
                .ignoresSafeArea()
                .allowsHitTesting(true)
    }
}
