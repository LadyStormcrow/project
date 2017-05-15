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
    dynamic var name: String = ""
    //    dynamic var dateCreated: NSDate?
    //    dynamic var dateModified: NSDate?
    //    dynamic var directoryPath: String?
    //    dynamic var noteId: Int
    
    //    init(noteName: String, dateC: NSDate, dateMod: NSDate, directory: String, id: Int) {
    //        self.name = noteName
    //        self.dateCreated = dateC
    //        self.dateModified = dateMod
    //        self.directoryPath = directory
    //        self.noteId = id
    //    }
    
    func save() {
        
    }
    
    func load(){
        
    }

}
