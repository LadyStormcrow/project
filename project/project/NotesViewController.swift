//
//  NotesViewController.swift
//  project
//
//  Created by Nicola Thouliss on 6/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//
//Search bar functionality was implemented with assisstance from this tutorial https://www.raywenderlich.com/113772/uisearchcontroller-tutorial

import UIKit
import Foundation
import RealmSwift


class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var data: Results<Note>!

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var notes: Array<Note>!
    var filteredNotes: Array<Note>!
    
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "viewNoteSegue", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm() //NEED TO CATCH EXCEPTION HERE!!
        data = realm.objects(Note.self)
        notes = Array(data)
        filteredNotes = Array(data)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    //Stack Overflow: https://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    //Stack Overflow: https://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredNotes = notes.filter({(note: Note) -> Bool in return ((note.name.lowercased().range(of: searchText.lowercased())) != nil)})
        tableView.reloadData()
    }
    
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filteredNotes.count
        } else {
            return self.data.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! TableCellTableViewCell
        let note: Note
        if searchController.isActive && searchController.searchBar.text! != "" {
            note = filteredNotes[indexPath.row]
        } else {
            note = data[indexPath.row]
        }
        
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
            let upcoming: CanvasMainViewController = segue.destination
                as! CanvasMainViewController
            upcoming.isNewItem = true
        }
        
        else if (segue.identifier == "loadNoteSegue") {
            let upcoming: CanvasMainViewController = segue.destination
                as! CanvasMainViewController
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

extension NotesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
