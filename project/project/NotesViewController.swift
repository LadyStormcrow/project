//
//  NotesViewController.swift
//  project
//
//  Created by Nicola Thouliss on 6/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import Foundation
//import RealmSwift


class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let notes = [Notes]()
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        
        data.append("note\(self.data.count + 1)")
        let indexPath: IndexPath = IndexPath(row: (self.data.count - 1), section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        self.performSegue(withIdentifier: "viewNoteSegue", sender: nil)
    }
    
    var data: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.notes.count
        return self.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! TableCellTableViewCell
        
        let note = data[indexPath.row]
        //let note = notes[indexPath.row]
        cell.noteName.text = note
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        self.performSegue(withIdentifier:"viewNoteSegue", sender: self)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
