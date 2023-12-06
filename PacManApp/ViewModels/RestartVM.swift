//
//  RestartVM.swift
//  PacManApp
//
//  Created by Mollie Whaley on 12/5/23.
//

import SwiftUI

class RestartGameVM: ObservableObject {
    
    @Published var shouldRestartGame: Bool = false
    
    func restartGame() {
        shouldRestartGame = true
    }
}
