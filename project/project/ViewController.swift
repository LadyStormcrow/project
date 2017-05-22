//
//  ViewController.swift
//  project
//
//  Created by Nicola Thouliss on 3/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import RealmSwift
@IBDesignable

class ViewController: UIViewController {
    
    let realm = try! Realm() //NEED TO CATCH EXCEPTION HERE!!
    var data: Results<NoteObject>!
    var isNewItem: Bool?
    var selectedNote: NoteObject?
    
    @IBOutlet weak var canvasView: CanvasView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = self.realm.objects(NoteObject.self)
        
        if !(isNewItem!) {
            print(selectedNote!.directoryPath)
            let myImage = loadNote(fileURL: selectedNote!.directoryPath)
            canvasView.image = myImage
        }
        
    }
    
    
    @IBAction func textButton() {
        
    }
    
    @IBAction func saveButton() {
        
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy, HH:mm:ssZZZZZ"
        let convertedDate = dateFormatter.string(from: currentDate as Date)
        let newNote = NoteObject()
        newNote.name = convertedDate
        newNote.created = currentDate
        
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, 0.0)
        canvasView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let imageData = UIImagePNGRepresentation(image!)
        
        do {
            
            let documentsURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            
            let fileURL = documentsURL.appendingPathComponent("\(newNote.name)").appendingPathExtension("png")
            
            newNote.directoryPath = "\(newNote.name).png"
            
            try imageData?.write(to: fileURL, options: .atomic)
            
        } catch {
            print(error)
        }

        try! self.realm.write {
            realm.add(newNote)
        }
    }
    
    
    @IBAction func btnPushButton(button: ColourButton) {
        if button.isBlueButton {
            canvasView.drawColor = UIColor(red: 0.1215686275, green: 0.5921568627, blue: 1.0, alpha: 1.0)
        } else if button.isBlackButton {
            canvasView.drawColor = UIColor.black
        } else if button.isRedButton {
            canvasView.drawColor = UIColor(red: 0.9803921569, green: 0.1607843137, blue: 0.2784313725, alpha: 1.0)
        } else if button.eraser {
            canvasView.drawColor = UIColor.white
        }
    }
    
    
    func loadNote(fileURL: String) -> UIImage {
        let documentsURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        let filePath = documentsURL.appendingPathComponent(fileURL)
        let image = UIImage(contentsOfFile: filePath.path)
        return image!
    }
    
    
    // Shake to clear screen
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        canvasView.clearCanvas(animated: true)
    }


}

