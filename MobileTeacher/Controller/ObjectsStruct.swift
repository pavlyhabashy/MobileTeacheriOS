//
//  ObjectsStruct.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 10/23/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import Foundation

struct Objects : Hashable {
    static func == (lhs: Objects, rhs: Objects) -> Bool {
        return lhs.tag == rhs.tag && lhs.list == rhs.list
    }
    var tag : String!
    var selected: Bool!
    var list : [Video]!
}
