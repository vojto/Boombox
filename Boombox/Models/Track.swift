//
//  Track.swift
//  Boombox
//
//  Created by Vojtech Rinik on 17/10/2019.
//  Copyright © 2019 Vojtech Rinik. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import SwiftyJSON

typealias Signal = PassthroughSubject<Void, Never>

class TracksManager: ObservableObject {
    @Published var tracks: [Track] = [Track(title: "testing", artist: "...")]
    
    init() {
        // Load some songs
        let alamofire = AppDelegate.instance.alamofire
        
    alamofire.request("https://api.spotify.com/v1/me/tracks").validate().responseData { (response) in
            guard let data = response.result.value else {
                return
            }
            let json = try! JSON(data: data)

            var tracks: [Track] = []
            let items = json["items"].array!
            
            for item in items {
                let track = item["track"].dictionary!
                let name = track["name"]!.string!
                let artists = track["artists"]!.array!
                let artist = artists[0]
                let artistName = artist["name"].string!
            
                
                let obj = Track(title: name, artist: artistName)
                tracks.append(obj)
            }
            
            self.tracks = tracks
            

//
//            var tracks: [Track] = []
//
//            for itemData in items {
//                let item = itemData as! NSDictionary
//                let track = item["track"] as! NSDictionary
//                let name = track["name"] as! String
//
//
//                let obj = Track(title: name, artist: "...")
//                tracks.append(obj)
//            }
//
//            self.tracks = tracks
//
//            print("showing \(self.tracks.count) tracks")
        }
        

    }
}

class Track: Hashable, Equatable {    
    let title: String
    let artist: String
    
    init(title: String, artist: String) {
        self.title = title
        self.artist = artist
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(artist)
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
