//
//  DrawView.swift
//  TouchTracker
//
//  Created by k_sabbak on 7/19/16.
//  Copyright © 2016 k_sabbak. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    
    var currentOvals = [NSValue:Line]()
    var finishedOvals = [Line]()

    @IBInspectable var finishedLineColor: UIColor = .blackColor() {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = .blueColor() {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    
    func strokeLine(line: Line)
    {
        let path = UIBezierPath()
        
        path.lineWidth = lineThickness
        path.lineCapStyle = CGLineCap.Round
        
        path.moveToPoint(line.begin)
        path.addLineToPoint(line.end)
        path.stroke()
    }
    
    func makeOval(line: Line)
    {
        let path = UIBezierPath()
        
        path.be
    }
    
    override func drawRect(rect: CGRect)
    {
        //Draw finished lines in black
        finishedLineColor.setStroke()
        
        for line in finishedLines
        {
            strokeLine(line)
        }
        
//        if let line = currentLine
//        {
//            //If there's a line currently being drawn it'll be blue
//            UIColor.blueColor().setStroke()
//            strokeLine(line)
//        }
        
        
        
        //currentLineColor.setStroke()
        for (_, line) in currentLines
        {
            
            let angle = (atan2(line.end.x - line.begin.x, line.end.y - line.begin.y) + 4)/10
            print("~~~~~~~~~~~~~~~~~~~~~~~~~~~ANGLE: \(angle)")
            
            UIColor.init(hue: angle, saturation: 1.0, brightness: 1.0, alpha: 1.0).setStroke()
            strokeLine(line)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
//        let touch = touches.first!
//        
//        //Get location of the touch in view's coordinate system
//        let location = touch.locationInView(self)
//        
//        
//        currentLine = Line(begin: location, end: location)
        
        //Let's put in a log statement to see the order of events I guess?
        print(#function)
        
        
        for touch in touches
        {
            let location = touch.locationInView(self)
            
            let newLine = Line(begin: location, end: location)
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }
        
        if currentLines.count == 2
        {
       
            
            currentOvals = currentLines
            currentLines.removeAll()
        }
        
        print("OMG OVALS \(currentOvals)")
        setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        print(#function)
        
        for touch in touches
        {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch .locationInView(self)
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
//        if var line = currentLine
//        {
//            let touch = touches.first!
//            let location = touch.locationInView(self)
//            line.end = location
//            
//            finishedLines.append(line)
//        }
        //currentLine = nil
        
        print(#function)
        
        for touch in touches
        {
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key]
            {
                line.end = touch.locationInView(self)
                
                finishedLines.append(line)
                currentLines.removeValueForKey(key)
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }

}
