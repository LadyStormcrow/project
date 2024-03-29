//
//  CGDrawingEngine.swift
//  project
//
//  Created by Nicola Thouliss on 7/06/2017.
//  Copyright © 2017 nstho4. All rights reserved.
//  Implementation helped by https://developer.apple.com/library/content/samplecode/SpeedSketch/Introduction/Intro.html


import UIKit


enum StrokeViewDisplayOptions {
    case debug
    case calligraphy
    case ink
}


class StrokeCGView: UIView {
    var displayOptions = StrokeViewDisplayOptions.ink { //default pen is in ink
        didSet {
            if strokeCollection != nil {
                setNeedsDisplay()
            }
        }
    }
    
    var strokeCollection: StrokeCollection? {
        didSet {
            if oldValue !== strokeCollection {
                setNeedsDisplay()
            }
            if let lastStroke = strokeCollection?.strokes.last {
                setNeedsDisplay(for: lastStroke)
            }
            strokeToDraw = strokeCollection?.activeStroke
        }
    }
    
    var strokeToDraw: Stroke? {
        didSet {
            if oldValue !== strokeToDraw && oldValue != nil {
                setNeedsDisplay()
            } else {
                if let stroke = strokeToDraw {
                    setNeedsDisplay(for: stroke)
                }
            }
        }
    }
    
    // MARK: Dirty rect calculation and handling.
    var dirtyRectViews: [UIView]!
    var lastEstimatedSample: (Int, StrokeSample)?
    
    func dirtyRects(for stroke:Stroke) -> [CGRect] {
        var result = [CGRect]()
        for range in stroke.updatedRanges() {
            var lowerBound = range.lowerBound
            if lowerBound > 0 { lowerBound -= 1 }
            
            if let (index, _) = lastEstimatedSample {
                if index < lowerBound {
                    lowerBound = index
                }
            }
            
            let samples = stroke.samples
            var upperBound = range.upperBound
            if upperBound < samples.count { upperBound += 1 }
            let dirtyRect = dirtyRectForSampleStride(stroke.samples[lowerBound..<upperBound])
            result.append(dirtyRect)
        }
        if stroke.predictedSamples.count > 0 {
            let dirtyRect = dirtyRectForSampleStride(stroke.predictedSamples[0..<stroke.predictedSamples.count])
            result.append(dirtyRect)
        }
        if let previousPredictedSamples = stroke.previousPredictedSamples {
            let dirtyRect = dirtyRectForSampleStride(previousPredictedSamples[0..<previousPredictedSamples.count])
            result.append(dirtyRect)
        }
        return result
    }
    
    func dirtyRectForSampleStride(_ sampleStride: ArraySlice<StrokeSample>) -> CGRect {
        var first = true
        var frame = CGRect.zero
        for sample in sampleStride {
            let sampleFrame = CGRect(origin: sample.location, size: .zero)
            if first {
                first = false
                frame = sampleFrame
            } else {
                frame = frame.union(sampleFrame)
            }
        }
        let maxStrokeWidth = CGFloat(20.0)
        return frame.insetBy(dx: -1 * maxStrokeWidth, dy: -1 * maxStrokeWidth)
    }
    
    func setNeedsDisplay(for stroke:Stroke) {
        for dirtyRect in dirtyRects(for: stroke) {
            setNeedsDisplay(dirtyRect)
        }
    }
    
    // MARK: Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.drawsAsynchronously = true
        
        let dirtyRectView = { () -> UIView in
            let view = UIView(frame: CGRect(x: -10, y: -10, width: 0, height: 0))
            view.layer.borderColor = UIColor.red.cgColor
            view.layer.borderWidth = 0.5
            view.isUserInteractionEnabled = false
            view.isHidden = true
            self.addSubview(view)
            return view
        }
        dirtyRectViews = [dirtyRectView(), dirtyRectView()]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Drawing methods.
    //Takes the stroke from the Stroke class to determine colour, width ect.
    
    var strokeColor = UIColor.black
    var fillColorRegular = UIColor.black.cgColor
    func draw(stroke: Stroke, in rect:CGRect, isActive active: Bool) {
        let displayOptions = self.displayOptions
        
        let updateRanges = stroke.updatedRanges()
        
        lastEstimatedSample = nil
        stroke.clearUpdateInfo()
        let sampleCount = stroke.samples.count
        guard sampleCount > 0 else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        
        let lineSettings: (()->())
        let forceEstimatedLineSettings: (()->())

        lineSettings = {
            context.setLineWidth(0.25)
            context.setStrokeColor(self.strokeColor.cgColor)
        }
        forceEstimatedLineSettings = lineSettings

        
        let azimuthSettings = {
            context.setLineWidth(1.5)
            context.setStrokeColor(UIColor.orange.cgColor)
        }
        let altitudeSettings = {
            context.setLineWidth(0.5)
            context.setStrokeColor(self.strokeColor.cgColor)
        }
        var forceMultiplier = CGFloat(2.0)
        var forceOffset = CGFloat(0.1)
        
        let fillColorCoalesced = UIColor.lightGray.cgColor
        let fillColorPredicted = UIColor.red.cgColor
        
        var lockedAzimuthUnitVector: CGVector?
        let azimuthLockAltitudeThreshold = CGFloat.pi / 2.0 * 0.80 // locking azimuth at 80% altitude
        
        lineSettings()
        
        var forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
            sample.forceWithDefault
        }
        
        if displayOptions == .ink {
            forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
                return sample.perpendicularForce
            }
        }
        
        // Make the force influence less pronounced for the calligraphy pen.
        if displayOptions == .calligraphy {
            let previousGetter = forceAccessBlock
            forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
                return max(previousGetter(sample), 1.0)
            }
            // make force value less pronounced
            forceMultiplier = 1.0
            forceOffset = 10.0
        }
        
        let previousGetter = forceAccessBlock
        forceAccessBlock = {(sample: StrokeSample) -> CGFloat in
            return previousGetter(sample) * forceMultiplier + forceOffset
        }
        
        var heldFromSample: StrokeSample?
        var heldFromSampleUnitVector: CGVector?
        
        func draw(segment: StrokeSegment) {
            if let toSample = segment.toSample {
                let fromSample: StrokeSample = heldFromSample ?? segment.fromSample
                
                // Skip line segments that are too short.
                if (fromSample.location - toSample.location).quadrance < 0.003 {
                    if heldFromSample == nil {
                        heldFromSample = fromSample
                        heldFromSampleUnitVector = segment.fromSampleUnitNormal
                    }
                    return
                }
                
                context.setFillColor(fillColorRegular)
                
                if displayOptions == .calligraphy {
                    
                    var fromAzimuthUnitVector = Stroke.calligraphyFallbackAzimuthUnitVector
                    var toAzimuthUnitVector   = Stroke.calligraphyFallbackAzimuthUnitVector
                    
                    if fromSample.azimuth != nil {
                        
                        if lockedAzimuthUnitVector == nil {
                            lockedAzimuthUnitVector = fromSample.azimuthUnitVector
                        }
                        fromAzimuthUnitVector = fromSample.azimuthUnitVector
                        toAzimuthUnitVector = toSample.azimuthUnitVector
                        if fromSample.altitude! > azimuthLockAltitudeThreshold {
                            fromAzimuthUnitVector = lockedAzimuthUnitVector!
                        }
                        if toSample.altitude! > azimuthLockAltitudeThreshold {
                            toAzimuthUnitVector = lockedAzimuthUnitVector!
                        } else {
                            lockedAzimuthUnitVector = toAzimuthUnitVector
                        }
                        
                    }
                    // Rotate 90 degrees
                    let calligraphyTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
                    fromAzimuthUnitVector = fromAzimuthUnitVector.apply(transform: calligraphyTransform)
                    toAzimuthUnitVector = toAzimuthUnitVector.apply(transform: calligraphyTransform)
                    
                    let fromUnitVector = fromAzimuthUnitVector * forceAccessBlock(fromSample)
                    let toUnitVector = toAzimuthUnitVector * forceAccessBlock(toSample)
                    
                    context.beginPath()
                    context.move(to: fromSample.location + fromUnitVector)
                    context.addLine(to: toSample.location + toUnitVector)
                    context.addLine(to: toSample.location - toUnitVector)
                    context.addLine(to: fromSample.location - fromUnitVector)
                    context.closePath()
                    
                    context.drawPath(using: .fillStroke)
                    
                } else {
                    
                    let fromUnitVector = (heldFromSampleUnitVector != nil ? heldFromSampleUnitVector! : segment.fromSampleUnitNormal) * forceAccessBlock(fromSample)
                    let toUnitVector = segment.toSampleUnitNormal * forceAccessBlock(toSample)
                    
                    let isForceEstimated = fromSample.estimatedProperties.contains(.force) || toSample.estimatedProperties.contains(.force)
                    if isForceEstimated {
                        if lastEstimatedSample == nil {
                            lastEstimatedSample = (segment.fromSampleIndex+1,toSample)
                        }
                        forceEstimatedLineSettings()
                    } else {
                        lineSettings()
                    }
                    
                    context.beginPath()
                    context.move(to: fromSample.location + fromUnitVector)
                    context.addLine(to: toSample.location + toUnitVector)
                    context.addLine(to: toSample.location - toUnitVector)
                    context.addLine(to: fromSample.location - fromUnitVector)
                    context.closePath()
                    context.drawPath(using: .fillStroke)
                }
                
                let isEstimated = fromSample.estimatedProperties.contains(.azimuth)
                if fromSample.azimuth != nil && (!fromSample.coalesced || isEstimated) && !fromSample.predicted && displayOptions == .debug {
                    
                    let length = CGFloat(20.0)
                    let azimuthUnitVector = fromSample.azimuthUnitVector
                    let azimuthTarget = fromSample.location + azimuthUnitVector * length
                    let altitudeStart = azimuthTarget + (azimuthUnitVector * (length / -2.0))
                    let altitudeTarget = altitudeStart + (azimuthUnitVector * (length / 2.0)).apply(transform: CGAffineTransform(rotationAngle: fromSample.altitude!))
                    
                    // Draw altitude as black line coming from the center of the azimuth.
                    altitudeSettings()
                    context.beginPath()
                    context.move(to: altitudeStart)
                    context.addLine(to: altitudeTarget)
                    context.strokePath()
                    
                    // Draw azimuth as orange (or blue if estimated) line.
                    azimuthSettings()
                    if isEstimated {
                        context.setStrokeColor(UIColor.blue.cgColor)
                    }
                    context.beginPath()
                    context.move(to: fromSample.location)
                    context.addLine(to: azimuthTarget)
                    context.strokePath()
                    
                }
                
                if heldFromSample != nil {
                    heldFromSample = nil
                    heldFromSampleUnitVector = nil
                }
            }
        }
        
        if stroke.samples.count == 1 {
            // Construct a face segment to draw for a stroke that is only one point.
            let sample = stroke.samples.first!
            let tempSampleFrom = StrokeSample(timestamp: sample.timestamp, location: sample.location + CGVector(dx: -0.5, dy: 0.0), coalesced: false, predicted: false, force: sample.force, azimuth: sample.azimuth, altitude: sample.altitude, estimatedProperties: sample.estimatedProperties, estimatedPropertiesExpectingUpdates: [])
            let tempSampleTo = StrokeSample(timestamp: sample.timestamp, location: sample.location + CGVector(dx: 0.5, dy: 0.0), coalesced: false, predicted: false, force: sample.force, azimuth: sample.azimuth, altitude: sample.altitude, estimatedProperties: sample.estimatedProperties, estimatedPropertiesExpectingUpdates: [])
            let segment = StrokeSegment(sample: tempSampleFrom)
            segment.advanceWithSample(incomingSample: tempSampleTo)
            segment.advanceWithSample(incomingSample: nil)
            
            draw(segment: segment)
        } else {
            for segment in stroke {
                draw(segment:segment)
            }
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        //UIColor.white.set()
        //UIRectFill(rect)
        
        // Optimization opportunity: Draw the existing collection in a different view,
        // and only draw each time we add a stroke.
        if let strokeCollection = strokeCollection {
            for stroke in strokeCollection.strokes {
                draw(stroke: stroke, in: rect, isActive: false)
            }
        }
        
        if let stroke = strokeToDraw {
            draw(stroke: stroke, in: rect, isActive: true)
        }
    }
    
}
