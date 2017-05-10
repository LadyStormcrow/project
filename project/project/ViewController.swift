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

    @IBOutlet weak var textView: UITextView!
    
    
    @IBAction func textButton() {
        textView.isHidden = false
    }
    
    @IBAction func btnPushButton(button: ColourButton) {
        textView.isHidden = true
        
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
        textView.isHidden = true
        //canvasView.clearCanvas(animated:false)
        
    }
    
    // Shake to clear screen
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        canvasView.clearCanvas(animated: true)
    }


}

