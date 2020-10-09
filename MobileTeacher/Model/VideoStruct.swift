//
//  VideoStruct.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 9/18/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import Foundation

struct Video : Hashable {
    var title: String = ""
    var description: String = ""
    var tags: [String] = []
    var url: URL!
    var downloadURL: URL!
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var downloadLocation: URL!
    var storage = ""
    
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.url == rhs.url
    }
}
struct OfflinedVideo : Codable {
    var title: String
    var description: String
    var tags: [String]
    var url: URL
    var downloadURL: URL
    var hours: Int
    var minutes: Int
    var seconds: Int
    var downloadLocation: URL
}
struct Plist : Codable {
    var videos: [OfflinedVideo]
}
