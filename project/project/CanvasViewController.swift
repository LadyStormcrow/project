//
//  CanvasViewController.swift
//  project
//
import UIKit
import QuartzCore
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
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flexibleDimensions: UIViewAutoresizing = [.flexibleWidth, .flexibleHeight]
        
        let scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 108.0, width: view.frame.size.width, height: view.frame.size.height))
        scrollView.autoresizingMask = flexibleDimensions
        view.insertSubview(scrollView, at: 0)
        self.scrollView = scrollView
        
        let imageSetup = UIImageView(frame: CGRect(x: 0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height))
        self.imageView = imageSetup
        scrollView.addSubview(imageSetup)
        imageView.backgroundColor = UIColor.clear
        
        let canvasView = StrokeCGView(frame: CGRect(x: 0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height))
        canvasView.autoresizingMask = flexibleDimensions
        
        self.cgView = canvasView
        
        cgView.isUserInteractionEnabled = true
        pageFinish = canvasView.frame.size.height
        
        
        scrollView.contentSize = cgView.bounds.size
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.addSubview(canvasView)
        
        print(scrollView.subviews)
        print(scrollView.subviews.count)
        
        view.backgroundColor = UIColor.white
        
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.white
        cgView.backgroundColor = .clear
        
        
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
            let myImage = loadNote(fileURL: selectedNote!.directoryPath)
            imageView.image = myImage
        }
    }
    
    @IBAction func addPage() {
        cgView.frame.size.height = pageFinish + 1024
        scrollView.contentSize = cgView.bounds.size
        cgView.setNeedsDisplay()
        pageFinish = (pageFinish + 1024)
        
    }
    
    
    @IBAction func saveButton() {
        
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy, HH:mm:ssZZZZZ"
        let convertedDate = dateFormatter.string(from: currentDate as Date)
        
        if !(isNewItem!) {
            let note = selectedNote!
            let notePath = note.directoryPath
            let filePath = documentDirectory().appendingPathComponent(notePath)
            
            let noteImage = captureNote()
            let image = UIImagePNGRepresentation(noteImage)
            
            try! image?.write(to: filePath, options: .atomic)
            
            try! realm.write {
                note.modified = currentDate
            }
            
        } else {
        
            let newNote = NoteObject()
            newNote.name = convertedDate
            newNote.created = currentDate
            
            let image = captureNote()
            let imageData = UIImagePNGRepresentation(image)
            
            let documents = documentDirectory()
            let fileURL = documents.appendingPathComponent("\(newNote.name)").appendingPathExtension("png")
            
            try! imageData?.write(to: fileURL, options: .atomic)
            
            newNote.directoryPath = "\(newNote.name).png"
            
            try! self.realm.write {
                realm.add(newNote)
            }
            
                //            UIGraphicsBeginPDFContextToFile(fileURL.path, cgView.bounds, nil)
                //            UIGraphicsBeginPDFPageWithInfo(cgView.bounds, nil)
                //
                //            let context = UIGraphicsGetCurrentContext()!
                //
                //            //cgView.drawHierarchy(in: cgView.bounds, afterScreenUpdates: false)
                //            UIGraphicsPDFRenderer(bounds: cgView.bounds)
                //
                //            UIGraphicsEndPDFContext()
            
        }
    }
    
    func loadNote(fileURL: String) -> UIImage {
        let documents = documentDirectory()
        let filePath = documents.appendingPathComponent(fileURL)
        let image = UIImage(contentsOfFile: filePath.path)
        return image!
    }
    
    func documentDirectory()-> URL {
        
            
        let documentsURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        
        return documentsURL
        
    }
    
    func captureNote() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(cgView.bounds.size, false, 0.0)
        cgView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!
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
                if let view = fingerStrokeRecognizer.view {
                    view.removeGestureRecognizer(fingerStrokeRecognizer)
                }
            } else {
                scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
                if fingerStrokeRecognizer.view == nil {
                    scrollView.addGestureRecognizer(fingerStrokeRecognizer)
                }
            }
        }
    }
    
    
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


