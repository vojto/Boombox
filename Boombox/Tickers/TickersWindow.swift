//
//  TickersWindow.swift
//  Boombox
//
//  Created by Vojtech Rinik on 19/10/2019.
//  Copyright © 2019 Vojtech Rinik. All rights reserved.
//

import Cocoa
import SwiftUI


class TickersWindow: NSWindow {
    let tickersManager = TickersManager()
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        let contentView = TickersView()
            .environmentObject(tickersManager)
        self.contentView = NSHostingView(rootView: contentView)
        
        self.updateFrame()
        
        self.level = .popUpMenu
    }

    
    func updateFrame() {
        guard let screen = NSScreen.main else { return }
        let screenSize = screen.frame.size
        
        let height = 20
        self.setFrame(NSRect(x: 0, y: 0, width: Int(screenSize.width), height: height), display: true)
    }
}
