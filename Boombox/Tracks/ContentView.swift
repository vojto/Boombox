//
//  ContentView.swift
//  Boombox
//
//  Created by Vojtech Rinik on 12/10/2019.
//  Copyright © 2019 Vojtech Rinik. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SongsTable()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
