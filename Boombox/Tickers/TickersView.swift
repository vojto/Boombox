//
//  TickersView.swift
//  Boombox
//
//  Created by Vojtech Rinik on 20/10/2019.
//  Copyright © 2019 Vojtech Rinik. All rights reserved.
//

import SwiftUI

struct TickersView: View {
    @EnvironmentObject var tickersManager: TickersManager
    
    let padding = EdgeInsets(top: 3.0, leading: 8.0, bottom: 2.0, trailing: 8.0)
    let font = Font.system(size: 12.0, weight: .medium, design: .monospaced)
    
    var body: some View {
        HStack(spacing: 0.0) {
            ForEach(tickersManager.tickers, id: \.self) { ticker in
                HStack {
                    Text(ticker.symbol).font(self.font)
                    Text(String(ticker.currentValue ?? 0)).font(self.font)
                    
                }.onTapGesture {
                    print("tapped ticker")
                }
                .padding(self.padding)
                .overlay(Border())
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

