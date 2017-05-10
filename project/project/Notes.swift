//
//  Notes.swift
//  project
//
//  Created by Nicola Thouliss on 6/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import Foundation
//import RealmSwift

class Notes: NSObject {
    var name: String?
    var dateCreated: NSDate?
    var dateModified: NSDate?
    var directoryPath: String?
    var noteId: Int?
    
    init(noteName: String, dateC: NSDate, dateMod: NSDate, directory: String, id: Int) {
        self.name = noteName
        self.dateCreated = dateC
        self.dateModified = dateMod
        self.directoryPath = directory
        self.noteId = id
    }
    
    func save() {
        
    }
    
    func load(){
        
    }

}
