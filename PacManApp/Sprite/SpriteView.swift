//
//  SpriteView.swift
//  PacManApp
//
//  Created by Mollie Whaley on 12/5/23.
//

import SpriteKit
import SwiftUI

struct SpriteView: UIViewRepresentable {
    
    typealias UIViewType = SKView
    
    var skScene: SKScene!
    
    init(scene: SKScene) {
        skScene = scene
        self.skScene.scaleMode = .resizeFill
    }
    
    class Coordinator: NSObject {
        var scene: SKScene?
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.scene = self.skScene
        return coordinator
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        view.presentScene(context.coordinator.scene)
    }
}
