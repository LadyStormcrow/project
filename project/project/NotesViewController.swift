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

    
    var data: Results<NoteObject>!

    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "viewNoteSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm() //NEED TO CATCH EXCEPTION HERE!!
        data = try! realm.objects(NoteObject.self)
        
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
        cell.configureWithNote(note)
        cell.noteName.text = note.name
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        self.performSegue(withIdentifier:"loadNoteSegue", sender: self)
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
