//
//  ContentView.swift
//  AudioInfoDemo
//
//  Created by Dzmitry Kryvalapau on 23.07.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var audioState = AudioState()
    
    var body: some View {
        AudioInfoView(audioState: audioState);
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
