//
//  HomeScreenView.swift
//  PacManApp
//
//  Created by Mollie Whaley on 11/5/23.
//

import SwiftUI

struct HomeScreenView: View {
    
    @State private var goToGame: Bool = false
    var body: some View {
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack{
                Images(image: "logo", width: 250, height: 165)
                
                HStack {
                    HStack(spacing: 15) {
                        Images(image: "blue-ghost", width: 45, height: 50)
                        Images(image: "green-ghost", width: 45, height: 50)
                        Images(image: "red-ghost", width: 45, height: 50)
                    }
                    .padding(.horizontal, 22)
                    
                    Images(image: "pacman", width: 45, height: 50)
                        .padding(.horizontal, 22)
                }
                
                self.navigateToButton
            }
        }
        .fullScreenCover(isPresented: self.$goToGame) {
            ContentView()
        }
    }
}

extension HomeScreenView {
    
    private var navigateToButton: some View {
        Button {
            self.goToGame = true
        } label: {
            Text("TAP TO ENTER")
                .foregroundColor(.white)
                .font(Font.custom("SometypeMono-Bold", size: 28))
                .padding(30)
        }
    }
}
struct Images: View {
    
    let image: String
    let width: Int
    let height: Int
    
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: CGFloat(width), height: CGFloat(height))
            .scaledToFit()
    }
}
