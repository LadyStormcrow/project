//
//  File.swift
//  project
//
//  Created by Nicola Thouliss on 10/06/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import RealmSwift

class Note: Object {
    dynamic var noteId = NSUUID().uuidString
    dynamic var name: String = ""
    dynamic var created: NSDate = NSDate()
    dynamic var modified: NSDate = NSDate()
    dynamic var directoryPath: String = ""
    dynamic var x: Double = 0.0
    dynamic var y: Double = 0.0
    dynamic var width: Double = 0.0
    dynamic var height: Double = 0.0
    
    override class func primaryKey() -> String{
        return "noteId"
    }
}
