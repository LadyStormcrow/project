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
    
//    func createTextField() {
//        let frame = CGRect(x: 0, y: 108.0, width: 1024.0, height: 660.0)
//        let textView = UITextField(frame: frame)
//        canvasView.addSubview(textView)
//    }

    
    @IBAction func textButton() {
        
    
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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //canvasView.clearCanvas(animated:false)
        
    }
    
    // Shake to clear screen
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        canvasView.clearCanvas(animated: true)
    }


}

