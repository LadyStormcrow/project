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
    
    var cellNote: NoteObject! = nil
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
        let aSelector: Selector = #selector(TableCellTableViewCell.noteNameTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        noteName.addGestureRecognizer(tapGesture)
    }
    
    func noteNameTapped() {
        noteName.isHidden = true
        changeNameField.isHidden = false
        changeNameField.text = noteName.text
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        changeNameField.isHidden = true
        noteName.isHidden = false
        noteName.text = changeNameField.text
        let documentsURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        let fileURL = documentsURL.appendingPathComponent("\(cellNote.name)").appendingPathExtension("png")
        try! FileManager.default.moveItem(at: fileURL, to: documentsURL.appendingPathComponent("\(noteName.text!)").appendingPathExtension("png"))
        try! realm.write {
            cellNote.name = noteName.text!
            cellNote.directoryPath = "\(noteName.text!).png"
        }


        return true
    }
}
