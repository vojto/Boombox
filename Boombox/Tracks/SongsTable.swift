//
//  SongsTable.swift
//  Boombox
//
//  Created by Vojtech Rinik on 17/10/2019.
//  Copyright © 2019 Vojtech Rinik. All rights reserved.
//

import SwiftUI
import Combine

struct SongsTable: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var tracksManager: TracksManager
    
    @State var selectedTracks: Set<Track> = Set()
    
    var body: some View {
        List(tracksManager.tracks, id: \.self, selection: $selectedTracks) { track in
            HStack {
                Text(track.title)
                    .lineLimit(1)
                    .frame(width: 200, alignment: .leading)
                Text(track.artist)
                Spacer()
            }.onTapGesture {
                print("tapped track!")
            }
        }
    }
}

