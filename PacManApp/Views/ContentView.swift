//
//  ContentView.swift
//  PacManApp
//
//  Created by Mollie Whaley on 10/14/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @StateObject private var restartVM: RestartGameVM = RestartGameVM()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            SpriteView(scene: SpriteScene(restartVM: restartVM, size: CGSize(width: 300, height: 400)))
        }
    }
}
