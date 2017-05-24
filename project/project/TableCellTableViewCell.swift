//
//  TableCellTableViewCell.swift
//  project
//
//  Created by Nicola Thouliss on 6/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import RealmSwift

class TableCellTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var noteId: String?

    @IBOutlet weak var noteName: UILabel!
    @IBOutlet weak var changeNameField: UITextField!
    
    let realm = try! Realm()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initalView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithNote(_ note: NoteObject){
        noteId = note.noteId
    }
    
    func initalView() {
        changeNameField.delegate = self
        changeNameField.isHidden = true
        noteName.isUserInteractionEnabled = true
        let aSelector: Selector = "noteNameTapped"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        noteName.addGestureRecognizer(tapGesture)
    }
    
    func noteNameTapped() {
        noteName.isHidden = true
        changeNameField.isHidden = false
        changeNameField.text = noteName.text
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField, note: NoteObject) -> Bool {
        textField.resignFirstResponder()
        changeNameField.isHidden = true
        noteName.isHidden = false
        noteName.text = changeNameField.text
        note.name = noteName.text!
        return true
    }
}
