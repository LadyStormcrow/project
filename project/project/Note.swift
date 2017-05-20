//
//  Note.swift
//  project
//
//  Created by Nicola Thouliss on 15/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class Note: Object {
    dynamic var noteId = NSUUID().uuidString
    dynamic var name: String = ""
    dynamic var created: NSDate = NSDate()
    //    dynamic var dateModified: NSDate?
    dynamic var directoryPath: String = ""
    //    dynamic var noteId: Int

    override class func primaryKey() -> String{
        return "noteId"
    }


}
