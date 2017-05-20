//
//  NoteObject.swift
//  project
//
//  Created by Nicola Thouliss on 20/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import RealmSwift

class NoteObject: Object {
    dynamic var noteId = NSUUID().uuidString
    dynamic var name: String = ""
    dynamic var created: NSDate = NSDate()
    dynamic var modified: NSDate = NSDate()
    dynamic var directoryPath: String = ""
    
    override class func primaryKey() -> String{
        return "noteId"
    }
}
