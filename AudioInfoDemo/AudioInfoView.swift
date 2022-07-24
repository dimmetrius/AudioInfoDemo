//
//  AudioInfoView.swift
//  AudioInfoDemo
//
//  Created by Dzmitry Kryvalapau on 23.07.22.
//

import SwiftUI

struct AudioInfoView: View {
    @ObservedObject var audioState: AudioState

    var body: some View {
        VStack {
            Text("AudioInfoDemo")
            Button("Get Info") {
                audioState.addItem("User requested info");
            }
            List {
                ForEach(audioState.rows) { row in
                    Text(row.name)
                }
            }
        }
    }
}

struct AudioInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AudioInfoView(audioState: AudioState())
    }
}
