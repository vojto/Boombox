//
//  Border.swift
//  Boombox
//
//  Created by Vojtech Rinik on 20/10/2019.
//  Copyright © 2019 Vojtech Rinik. All rights reserved.
//

import SwiftUI

struct Border: View {
    var body: some View {
        GeometryReader { geom in
            Path { path in
                path.move(to: CGPoint(x: geom.size.width, y: 0))
                path.addLine(to: CGPoint(x: geom.size.width, y: geom.size.height))
            }.stroke(Color.black, lineWidth: 2.0)
        }
    }
}

