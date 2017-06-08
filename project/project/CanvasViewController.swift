//
//  CanvasViewController.swift
//  project
//
//  Created by Nicola Thouliss on 8/06/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//

import UIKit
import RealmSwift

class CanvasMainViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let realm = try! Realm() //NEED TO CATCH EXCEPTION HERE!!
    var data: Results<NoteObject>!
    var isNewItem: Bool?
    var selectedNote: NoteObject?
    var canvasView: StrokeCGView!
    var pageFinish: CGFloat!
    
    var cgView: StrokeCGView!
    //var leftRingControl: RingControl!
    
    var fingerStrokeRecognizer: StrokeGestureRecognizer!
    var pencilStrokeRecognizer: StrokeGestureRecognizer!
    
    var clearButton: UIButton!
    
    var configurations = [() -> ()]()
    
    var strokeCollection = StrokeCollection()
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flexibleDimensions: UIViewAutoresizing = [.flexibleWidth, .flexibleHeight]
        
        let scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 108.0, width: view.frame.size.width, height: view.frame.size.height))
        scrollView.autoresizingMask = flexibleDimensions
        view.addSubview(scrollView)
        self.scrollView = scrollView
        
        let canvasView = StrokeCGView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        canvasView.autoresizingMask = flexibleDimensions
        self.cgView = canvasView
        
        canvasView.isUserInteractionEnabled = true
        pageFinish = canvasView.frame.size.height
        
        scrollView.contentSize = cgView.bounds.size
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.addSubview(canvasView)
        
        view.backgroundColor = UIColor.white
        
        scrollView.panGestureRecognizer.allowedTouchTypes = [UITouchType.direct.rawValue as NSNumber]
        scrollView.pinchGestureRecognizer?.allowedTouchTypes = [UITouchType.direct.rawValue as NSNumber]
        scrollView.delegate = self
        
        
        // We put our UI elements on top of the scroll view, so we don't want any of the
        // delay or cancel machinery in place.
        scrollView.delaysContentTouches = false
        
        let fingerStrokeRecognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
        fingerStrokeRecognizer.delegate = self
        fingerStrokeRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(fingerStrokeRecognizer)
        fingerStrokeRecognizer.coordinateSpaceView = cgView
        fingerStrokeRecognizer.isForPencil = false
        self.fingerStrokeRecognizer = fingerStrokeRecognizer
        
        let pencilStrokeRecognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
        pencilStrokeRecognizer.delegate = self
        pencilStrokeRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(pencilStrokeRecognizer)
        pencilStrokeRecognizer.coordinateSpaceView = cgView
        pencilStrokeRecognizer.isForPencil = true
        self.pencilStrokeRecognizer = pencilStrokeRecognizer
        
        setupPencilUI()
        
        if !(isNewItem!) {
            print(selectedNote!.directoryPath)
            let myImage = loadNote(fileURL: selectedNote!.directoryPath)
            //canvasView.image = myImage
        }
    }

    @IBAction func addPage() {
        print(pageFinish)
        let myView = StrokeCGView(frame: CGRect(x: 0, y: pageFinish, width: 1024, height: 1024))
        myView.isUserInteractionEnabled = true
        scrollView.addSubview(myView)
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: pageFinish + 1024)
        pageFinish = (myView.frame.origin.y + 1024)
        
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
            let blue = UIColor(red: 0.1215686275, green: 0.5921568627, blue: 1.0, alpha: 1.0)
            cgView.strokeColor = blue
            cgView.fillColorRegular = blue.cgColor
        } else if button.isBlackButton {
            cgView.strokeColor = UIColor.black
            cgView.fillColorRegular = UIColor.black.cgColor
        } else if button.isRedButton {
            let red = UIColor(red: 0.9803921569, green: 0.1607843137, blue: 0.2784313725, alpha: 1.0)
            cgView.strokeColor = red
            cgView.fillColorRegular = red.cgColor
        } else if button.eraser {
            let white = UIColor.white
            cgView.strokeColor = white
            cgView.fillColorRegular = white.cgColor
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


    // MARK: View setup helpers.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func receivedAllUpdatesForStroke(_ stroke: Stroke) {
        cgView.setNeedsDisplay(for: stroke)
        stroke.clearUpdateInfo()
    }
    
    func clearButtonAction(_ sender: AnyObject) {
        self.strokeCollection = StrokeCollection()
        cgView.strokeCollection = self.strokeCollection
    }
    
    func strokeUpdated(_ strokeGesture: StrokeGestureRecognizer) {
        
        if strokeGesture === pencilStrokeRecognizer {
            lastSeenPencilInteraction = Date.timeIntervalSinceReferenceDate
        }
        
        var stroke: Stroke?
        if strokeGesture.state != .cancelled {
            stroke = strokeGesture.stroke
            if strokeGesture.state == .began ||
                (strokeGesture.state == .ended && strokeCollection.activeStroke == nil) {
                strokeCollection.activeStroke = stroke
                //leftRingControl.cancelInteraction()
            }
        } else {
            strokeCollection.activeStroke = nil
        }
        
        if let stroke = stroke {
            if strokeGesture.state == .ended {
                if strokeGesture === pencilStrokeRecognizer {
                    // Make sure we get the final stroke update if needed.
                    stroke.receivedAllNeededUpdatesBlock = { [weak self] in
                        self?.receivedAllUpdatesForStroke(stroke)
                    }
                }
                strokeCollection.takeActiveStroke()
            }
        }
        
        cgView.strokeCollection = strokeCollection
    }
    
    
    // MARK: Pencil Recognition and UI Adjustments
    /*
     Since usage of the Apple Pencil can be very temporary, the best way to
     actually check for it being in use is to remember the last interaction.
     Also make sure to provide an escape hatch if you modify your UI for
     times when the pencil is in use vs. not.
     */
    
    // Timeout the pencil mode if no pencil has been seen for 5 minutes and the app is brought back in foreground.
    let pencilResetInterval = TimeInterval(60.0 * 5)
    
    var lastSeenPencilInteraction: TimeInterval? {
        didSet {
            if lastSeenPencilInteraction != nil && !pencilMode {
                pencilMode = true
            }
        }
    }
    
    private func setupPencilUI() {
        self.pencilMode = false
        
        notificationObservers.append(
            NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: UIApplication.shared, queue: nil)
            { [unowned self](_) in
                if self.pencilMode &&
                    (self.lastSeenPencilInteraction == nil ||
                        Date.timeIntervalSinceReferenceDate - self.lastSeenPencilInteraction! > self.pencilResetInterval) {
                }
            }
        )
    }
    
    var notificationObservers = [NSObjectProtocol]()
    
    deinit {
        let defaultCenter = NotificationCenter.default
        for closure in notificationObservers {
            defaultCenter.removeObserver(closure)
        }
    }
    
    var pencilMode = false {
        didSet {
            if pencilMode {
                scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
                //pencilButton.isHidden = false
                if let view = fingerStrokeRecognizer.view {
                    view.removeGestureRecognizer(fingerStrokeRecognizer)
                }
            } else {
                scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
                //pencilButton.isHidden = true
                if fingerStrokeRecognizer.view == nil {
                    scrollView.addGestureRecognizer(fingerStrokeRecognizer)
                }
            }
        }
    }
    
    
    // Since our gesture recognizer is beginning immediately, we do the hit test ambiguation here
    // instead of adding failure requirements to the gesture for minimizing the delay
    // to the first action sent and therefore the first lines drawn.
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        
////        if leftRingControl.hitTest(touch.location(in:leftRingControl), with: nil) != nil {
////            return false
////        }
//    
//        
//        return true
//    }
    
    // We want the pencil to recognize simultaniously with all others.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === pencilStrokeRecognizer {
            return otherGestureRecognizer !== fingerStrokeRecognizer
        }
        
        return false
    }
    
    
}

extension CanvasMainViewController: UIScrollViewDelegate {
    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return self.canvasContainerView
//    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        var desiredScale = self.traitCollection.displayScale
        let existingScale = cgView.contentScaleFactor
        
        if scale >= 2.0 {
            desiredScale *= 2.0
        }
        
        if abs(desiredScale - existingScale) > 0.00001 {
            cgView.contentScaleFactor = desiredScale
            cgView.setNeedsDisplay()
        }
    }
}



