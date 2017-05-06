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

    @IBOutlet weak var tableView: UITableView!
    let notes = Notes()
    var table: [String] = ["Note1"]
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.table.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! TableCellTableViewCell
        
        cell.noteName.text = notes.name
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        //self.performSegue(withIdentifier:"viewMonsterFromSearchSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

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
