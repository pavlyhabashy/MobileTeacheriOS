//
//  VideoStruct.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 9/18/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import Foundation

struct Video {
    var title: String = ""
    var description: String = ""
    var tags: [String] = []
    var url: URL!
    var downloadURL: URL!
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var downloadLocation: URL!
}
