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
    var data: Results<NoteObject>!

    
    convenience init() {
        self.init()
        data = realm.objects(NoteObject.self)
    }

    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        
        let nameAlertController = UIAlertController(title: "Name note", message: "Please name your note", preferredStyle: .alert)
        
        let noteAction = UIAlertAction(title: "Add", style: .default) { [weak nameAlertController] _ in
            if let nameAlertController = nameAlertController {
                let noteNameTextField = nameAlertController.textFields![0] as UITextField
                //save Note to database
                let newNote = NoteObject()
                newNote.name = noteNameTextField.text!
                newNote.created = NSDate()
                try! self.realm.write() {
                    self.realm.add(newNote)
                }
            }
            self.performSegue(withIdentifier: "viewNoteSegue", sender: nil)
        }
        
        noteAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        nameAlertController.addTextField { textField in
            textField.placeholder = "Note name"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { notification in
                noteAction.isEnabled = textField.text != ""
            }
        }
        
        nameAlertController.addAction(noteAction)
        nameAlertController.addAction(cancelAction)
        
        self.present(nameAlertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        data = try! realm.objects(NoteObject.self)
        
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
        
        self.performSegue(withIdentifier:"viewNoteSegue", sender: self)
    }
    
    
    
//    func prepare(for segue: UIStoryboardSegue, sender: TableCellTableViewCell) {
//        
//        if (segue.identifier == "viewNoteSegue") { //if an item is clicked in list
//            let upcoming: ViewController = segue.destination
//                as! ViewController
//            let indexPath = self.tableView.indexPathForSelectedRow!
//            //show saved Note
//            
//
//            self.tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
