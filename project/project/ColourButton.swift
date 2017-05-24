//
//  ColourButton.swift
//  project
//
//  Created by Nicola Thouliss on 4/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
@IBDesignable


class ColourButton: UIButton {
    
    @IBInspectable var fillColor: UIColor = UIColor.green
    @IBInspectable var isBlueButton: Bool = true
    @IBInspectable var isBlackButton: Bool = true
    @IBInspectable var isRedButton: Bool = true
    @IBInspectable var eraser: Bool = true

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        
        
        if (eraser) {
            fillColor = UIColor.white
        }
        
        
        fillColor.setFill()
        path.fill()
    }

}
