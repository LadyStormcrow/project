//
//  CanvasViewController.swift
//  project
//  drawing functionality was implemented with assitance from https://developer.apple.com/library/content/samplecode/SpeedSketch/Introduction/Intro.html


import UIKit
import Foundation
import RealmSwift

class CanvasMainViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let realm = try! Realm() //NEED TO CATCH EXCEPTION HERE!!
    var data: Results<Note>!
    var isNewItem: Bool!
    var selectedNote: Note?
    var canvasView: StrokeCGView!
    var pageFinish: CGFloat!
    
    var cgView: StrokeCGView!
    var savedView: Bool = false
    
    var fingerStrokeRecognizer: StrokeGestureRecognizer!
    var pencilStrokeRecognizer: StrokeGestureRecognizer!
    
    var clearButton: UIButton!
    
    var configurations = [() -> ()]()
    
    var strokeCollection = StrokeCollection()
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var pageAdd: CGFloat!
    
    var undoStokes: Array<Stroke> = []
    @IBOutlet weak var redoButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    
    var startTimer = Timer() //timer for autosave
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let flexibleDimensions: UIViewAutoresizing = [.flexibleWidth, .flexibleHeight]
        
        let scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height))
        scrollView.autoresizingMask = flexibleDimensions
        view.insertSubview(scrollView, at: 0)
        self.scrollView = scrollView
        
        if !(isNewItem) {
            savedView = true
            
            let imageSetup = UIImageView(frame: CGRect(x: CGFloat(selectedNote!.x), y: CGFloat(selectedNote!.y), width: CGFloat(selectedNote!.width), height: CGFloat(selectedNote!.height)))
            self.imageView = imageSetup
            scrollView.addSubview(imageSetup)
            
            let canvasView = StrokeCGView(frame: CGRect(x: CGFloat(selectedNote!.x), y: CGFloat(selectedNote!.y), width: CGFloat(selectedNote!.width), height: CGFloat(selectedNote!.height)))
            canvasView.autoresizingMask = flexibleDimensions
            self.cgView = canvasView
            
        } else {
            let imageSetup = UIImageView(frame: CGRect(x: 0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height))
            self.imageView = imageSetup
            scrollView.addSubview(imageSetup)
            
            let canvasView = StrokeCGView(frame: CGRect(x: 0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height))
            canvasView.autoresizingMask = flexibleDimensions
            self.cgView = canvasView
        }
        
        imageView.backgroundColor = UIColor.clear
        
        pageAdd = view.frame.size.height
        
        cgView.isUserInteractionEnabled = true
        pageFinish = view.frame.size.height
        
        //set up scroll options
        scrollView.contentSize = cgView.bounds.size
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.addSubview(cgView)
        
        view.backgroundColor = UIColor.white
        
        //set up image view options
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.white
        cgView.backgroundColor = .clear
        
        
        scrollView.panGestureRecognizer.allowedTouchTypes = [UITouchType.direct.rawValue as NSNumber]
        scrollView.pinchGestureRecognizer?.allowedTouchTypes = [UITouchType.direct.rawValue as NSNumber]
        
        
        
        // We put our UI elements on top of the scroll view, so we don't want any of the
        // delay or cancel machinery in place.
        scrollView.delaysContentTouches = false
        
        //set finger stroke recongiser on scroll view, allows scroll
        let fingerStrokeRecognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
        fingerStrokeRecognizer.delegate = self
        fingerStrokeRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(fingerStrokeRecognizer)
        fingerStrokeRecognizer.coordinateSpaceView = cgView
        fingerStrokeRecognizer.isForPencil = false
        self.fingerStrokeRecognizer = fingerStrokeRecognizer
        
        //set penicl stroke recongiser, allows drawing
        let pencilStrokeRecognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
        pencilStrokeRecognizer.delegate = self
        pencilStrokeRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(pencilStrokeRecognizer)
        pencilStrokeRecognizer.coordinateSpaceView = cgView
        pencilStrokeRecognizer.isForPencil = true
        self.pencilStrokeRecognizer = pencilStrokeRecognizer
        
        setupPencilUI()
        if !(isNewItem) {
            let myImage = loadNote(fileURL: selectedNote!.directoryPath)
            imageView.image = myImage
        }
        
        //set up timer for autosave

        
        //disable undo and redo buttons
        undoButton.isEnabled = false
        redoButton.isEnabled = false
        
    }
    //add another page to the document
    @IBAction func addPage() {
        cgView.frame.size.height = pageFinish + pageAdd
        scrollView.contentSize = cgView.bounds.size
        cgView.setNeedsDisplay() //refresh view
        pageFinish = (pageFinish + pageAdd)
        
    }
    
    @IBAction func calligraphyBrush() {
        self.cgView.displayOptions = .calligraphy
    }

    @IBAction func inkBrush() {
        self.cgView.displayOptions = .ink
    }
    
    @IBAction func undo() {
        let lastStroke = self.cgView.strokeCollection?.strokes.last //get the last stroke
        let removeIndex = self.cgView.strokeCollection?.strokes.count //get the stroke index count
        if undoStokes.count == 10 { //only collect the last 10 undo items
            undoStokes = []
        }
        undoStokes.append(lastStroke!) //save last stroke so that it can be available for redo
        self.cgView.strokeCollection?.strokes.remove(at: removeIndex! - 1) //remove stroke
        redoButton.isEnabled = true
        cgView.setNeedsDisplay()
    }

    
    @IBAction func redo() {
        let lastUndoStroke = undoStokes.last!
        self.cgView.strokeCollection?.strokes.append(lastUndoStroke)
        undoStokes.remove(at: undoStokes.count - 1)
        if undoStokes.count == 0 {
            redoButton.isEnabled = false //disable the button so that user cannot undo on empty item
        }
        cgView.setNeedsDisplay()
    }
    
    func save() {
        
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy, HH:mm:ss" //get current date and time
        let convertedDate = dateFormatter.string(from: currentDate as Date)
        let noteHeight = Double(cgView.frame.size.height)
        let noteWidth = Double(cgView.frame.size.width)
        let noteX = Double(cgView.frame.origin.x)
        let noteY = Double(cgView.frame.origin.y)
        
        if !(isNewItem) || savedView { //check if the document has been saved before
            let note = selectedNote!
            let notePath = note.directoryPath
            let filePath = documentDirectory().appendingPathComponent(notePath)
            
            let noteImage = captureNote() //get an image of the note
            let image = UIImagePNGRepresentation(noteImage)
            
            try! image?.write(to: filePath, options: .atomic) //save as an image
            
            try! realm.write { //write a new note object
                note.modified = currentDate
                note.width = noteWidth
                note.height = noteHeight
                note.x = noteX
                note.y = noteY
            }
            
        } else { //if it hasn't been saved before
        
            let newNote = Note()
            newNote.name = convertedDate
            newNote.created = currentDate
            newNote.x = noteX
            newNote.y = noteY
            newNote.width = noteWidth
            newNote.height = noteHeight
            
            let image = captureNote()
            let imageData = UIImagePNGRepresentation(image)
            
            let documents = documentDirectory()
            let fileURL = documents.appendingPathComponent("\(newNote.name)").appendingPathExtension("png")
            
            try! imageData?.write(to: fileURL, options: .atomic)
            
            newNote.directoryPath = "\(newNote.name).png"
            
            try! self.realm.write {
                realm.add(newNote)
            }
            
            savedView = true
            selectedNote = newNote
        }
        

    }
    
    func loadNote(fileURL: String) -> UIImage { //get the image from the device
        let documents = documentDirectory()
        let filePath = documents.appendingPathComponent(fileURL)
        let image = UIImage(contentsOfFile: filePath.path)
        return image!
    }
    
    func documentDirectory()-> URL { //document sandbox path in device
        
        let documentsURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        
        return documentsURL
        
    }
    
    func captureNote() -> UIImage { //get the note
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()!
        imageView.drawHierarchy(in: view.bounds, afterScreenUpdates: true) //first get the image view image
        context.saveGState() //save context state
        cgView.drawHierarchy(in: view.bounds, afterScreenUpdates: true) //get the recently drawn stuff
        context.restoreGState() //restore state
        let image = UIGraphicsGetImageFromCurrentImageContext(); //get image
        
        UIGraphicsEndImageContext();
        
        return image!
    }

    
    
    @IBAction func btnPushButton(button: ColourButton) { //erase items
        if button.isBlackButton {
            let black = UIColor.black
            cgView.strokeColor = black
            cgView.fillColorRegular = black.cgColor
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
    
    func strokeUpdated(_ strokeGesture: StrokeGestureRecognizer) { //detects when stroke is being drawn
        
        if strokeGesture === pencilStrokeRecognizer {
            lastSeenPencilInteraction = Date.timeIntervalSinceReferenceDate
        }
        
        var stroke: Stroke?
        if strokeGesture.state != .cancelled {
            stroke = strokeGesture.stroke
            if strokeGesture.state == .began ||
                (strokeGesture.state == .ended && strokeCollection.activeStroke == nil) {
                strokeCollection.activeStroke = stroke
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
        
        //enable undo button when user draws on screen
        undoButton.isEnabled = true
        self.startTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(CanvasMainViewController.save), userInfo: nil, repeats: true)
    }
    
    
    // MARK: Pencil Recognition and UI Adjustments
    
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
                    self.startTimer.invalidate()
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
                scrollView.panGestureRecognizer.minimumNumberOfTouches = 1 //if finger is used, scroll
                if let view = fingerStrokeRecognizer.view {
                    view.removeGestureRecognizer(fingerStrokeRecognizer)
                }
            } else {
                scrollView.panGestureRecognizer.minimumNumberOfTouches = 1 //enable scroll right away if pencil is not being used
                if fingerStrokeRecognizer.view == nil { //set fingerStrokeRecongiser if it is not in the view
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
    
}


