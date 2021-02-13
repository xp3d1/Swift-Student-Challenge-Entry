//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit
import SwiftUI
import AVFoundation

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 830, height: 500))
var scene = GameScene(fileNamed: "GameScene")
    // Set the scale mode to scale to fit the window
scene!.scaleMode = .aspectFill
    // Present the scene
sceneView.presentScene(scene!)


var settings = UserSettings()
let cv = MainView(scene: scene!).environmentObject(settings)
let controller = NSHostingController(rootView: cv)
controller.view.frame = sceneView.frame
sceneView.addSubview(controller.view)
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = sceneView
