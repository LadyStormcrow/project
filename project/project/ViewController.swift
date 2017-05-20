//
//  ViewController.swift
//  project
//
//  Created by Nicola Thouliss on 3/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
@IBDesignable

class ViewController: UIViewController {
    
    
    @IBOutlet weak var canvasView: CanvasView!
    
    
    @IBAction func textButton() {
        
    }
    
    @IBAction func saveButton() {
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
    
//    func saveNote() {
//        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, 0.0)
//        canvasView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//        let image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        let data = UIImagePNGRepresentation(image!)
//        do {
//            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            let fileURL = documentsURL.appendingPathComponent("test.png")
//            
//            try data?.write(to: fileURL, options: .atomic)
//        } catch {
//            print(error)
//        }
//    }
//    
//    func loadNote() {
//        let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let fileURL = documentsURL.appendingPathComponent("test.png").path
//        let image = UIImage(contentsOfFile: fileURL)
//    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //canvasView.clearCanvas(animated:false)
        //canvasView.addSubview(textView)
        //print(canvasView.subviews)
        
    }
    
    // Shake to clear screen
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        canvasView.clearCanvas(animated: true)
    }


}

