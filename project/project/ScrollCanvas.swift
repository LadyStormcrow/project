//
//  ScrollCanvas.swift
//  project
//
//  Created by Nicola Thouliss on 11/05/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit

class ScrollCanvas: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let testFrame = CGRect(x: 0, y: 108, width: 1024, height: 660)
        let canvas = CanvasView(frame: testFrame)
        self.addSubview(canvas)
        
        let contentHeight: CGFloat = 1500.0
        
        self.contentSize = CGSize(width: self.frame.width, height: contentHeight)
        
    }

    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
