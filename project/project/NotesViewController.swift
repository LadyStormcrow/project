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


class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    var data: Results<NoteObject>!

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "viewNoteSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm() //NEED TO CATCH EXCEPTION HERE!!
        data = realm.objects(NoteObject.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! TableCellTableViewCell
        let note = data[indexPath.row]
        cell.cellNote = note
        cell.configureWithNote(note)
        cell.noteName.text = note.name
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        self.performSegue(withIdentifier:"loadNoteSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let documentsURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        
        if editingStyle == .delete {
            try! data.realm!.write {
                let note = self.data[indexPath.row]
                let fileURL = note.directoryPath
                let filePath = documentsURL.appendingPathComponent(fileURL)
                try! FileManager.default.removeItem(at: filePath)
                self.data.realm!.delete(note)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "viewNoteSegue") { //if an item is clicked in list
            let upcoming: ViewController = segue.destination
                as! ViewController
            upcoming.isNewItem = true
        }
        
        else if (segue.identifier == "loadNoteSegue") {
            let upcoming: ViewController = segue.destination
                as! ViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let note = data[indexPath.row]
            upcoming.selectedNote = note
            upcoming.isNewItem = false
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
