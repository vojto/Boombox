//
//  Ticker.swift
//  Boombox
//
//  Created by Vojtech Rinik on 19/10/2019.
//  Copyright © 2019 Vojtech Rinik. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let apiKey = "RW86J1OXR7V41HS0"

class TickersManager: ObservableObject {
    static let alamofire = SessionManager()
    
    let symbols = ["SPY", "QQQ", "VTI", "VNQ", "AAPL"]
    @Published var tickers: [Ticker] = []
    
    init() {
        for (index, symbol) in symbols.enumerated() {
            tickers.append(Ticker(symbol: symbol))
            self.loadTicker(atIndex: index)
        }
    }
    
    func loadTicker(atIndex index: Int) {
        let ticker = tickers[index]
        let alamofire = TickersManager.alamofire
        let url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(ticker.symbol)&interval=1min&apikey=\(apiKey)"
        
        alamofire.request(url).validate().responseData { (response) in
            guard let data = response.result.value else { return }
            
            let json = try! JSON(data: data)
            
            guard let timestamps = json["Time Series (1min)"].dictionary else {
                return
            }
            let sortedTimestamps = timestamps.keys.sorted().reversed()
            
            guard let firstTimestamp = sortedTimestamps.first else { return }
            guard let values = timestamps[firstTimestamp] else { return }
            
            guard let closeStr = values["4. close"].string else { return }
            guard let close = Double(closeStr) else { return }
            
            print("Updating current value to: \(close)")
            
            DispatchQueue.main.async {
                self.tickers[index].currentValue = close
            }
        }
    }
}

struct Ticker: Hashable, Equatable {
    var symbol: String
    var currentValue: Double?
    
    init(symbol: String) {
        self.symbol = symbol
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
    
    static func == (lhs: Ticker, rhs: Ticker) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
