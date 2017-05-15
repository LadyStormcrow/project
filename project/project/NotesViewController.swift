//
//  NotesViewController.swift
//  project
//
//  Created by Nicola Thouliss on 6/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let realm = try! Realm() //NEED TO CATCH EXCEPTION HERE!!
    var data: Results<Note> = try! Realm().objects(Note.self)
    
    convenience init() {
        self.init()
        data = realm.objects(Note.self)
    }


    @IBOutlet weak var tableView: UITableView!
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        
//        data.append("note\(self.data.count + 1)")
//        let indexPath: IndexPath = IndexPath(row: (self.data.count - 1), section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//        self.performSegue(withIdentifier: "viewNoteSegue", sender: nil)
    }
    
    func loadDefaultNotes() {
        if data.count == 0 {
            
            try! realm.write() {
                let defaultData = ["Note1", "Note2", "Note3"]
                
                for d in defaultData {
                    let newNotes = Note()
                    newNotes.name = d
                    self.realm.add(newNotes)
                }
            }
            
            data = realm.objects(Note.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDefaultNotes()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! TableCellTableViewCell
        
        let note = data[indexPath.row]
        cell.noteName.text = note.name
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        //self.performSegue(withIdentifier:"viewNoteSegue", sender: self)
    }
    
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if (segue.identifier == "viewNoteSegue") //if an item is clicked in list
//        {
//            let upcoming: ViewController = segue.destination
//                as! ViewController
//            let indexPath = self.tableView.indexPathForSelectedRow!
//            //show saved Note
//
//            self.tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
