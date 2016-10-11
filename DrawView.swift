//
//  DrawView.swift
//  TouchTracker
//
//  Created by k_sabbak on 7/19/16.
//  Copyright © 2016 k_sabbak. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate {
    
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    var moveRecognizer: UIPanGestureRecognizer!
    
    var selectedLineIndex: Int?
    {
        didSet
        {
            if selectedLineIndex == nil
            {
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool
    {
        return true
    }

    @IBInspectable var finishedLineColor: UIColor = .black {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = .blue {
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
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)
    
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.moveLine(_:)))
        moveRecognizer.delegate = self
        //moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
    }
    
    func strokeLine(line: Line)
    {
        let path = UIBezierPath()
        
        path.lineWidth = lineThickness
        path.lineCapStyle = CGLineCap.round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect)
    {
        //Draw finished lines in black
        finishedLineColor.setStroke()
        
        for line in finishedLines
        {
            strokeLine(line: line)
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
            strokeLine(line: line)
        }
        
        if let index = selectedLineIndex
        {
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            strokeLine(line: selectedLine)
            
            //setMenuLocation(selectedLine: finishedLines[index])
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
//        let touch = touches.first!
//        
//        //Get location of the touch in view's coordinate system
//        let location = touch.locationInView(self)
//        
//        
//        currentLine = Line(begin: location, end: location)
        
        //Let's put in a log statement to see the order of events I guess?
        
        selectedLineIndex = nil
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
        
        print(#function)
        
        
        for touch in touches
        {
            let location = touch.location(in: self)
            
            let newLine = Line(begin: location, end: location)
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print(#function)
        
        for touch in touches
        {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch .location(in: self)
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
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
                line.end = touch.location(in: self)
                
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
    
    func doubleTap(_ addGestureRecognizer: UITapGestureRecognizer)
    {
        print("Recognized a double tap, let's hope this is fine.")
        
        selectedLineIndex = nil
        currentLines.removeAll(keepingCapacity: false)
        finishedLines.removeAll(keepingCapacity: false)
        setNeedsDisplay()
    }
    
    func tap(_ gestureRegcognizer: UITapGestureRecognizer)
    {
        print("Recognized a tap, probably?")
        
        let point = gestureRegcognizer.location(in: self)
        selectedLineIndex = indexOfLineAtPoint(point: point)
        
        //Grab the menu controller
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil
        {
            //Make DrawView the target of menu item action messages
            becomeFirstResponder()
            
            //Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(self.deleteLine(_:)))
            menu.menuItems = [deleteItem]
            
            //Tell the menu where it should come from and show it
            let selectLine = finishedLines[selectedLineIndex!]
            
            setMenuLocation(selectedLine: selectLine)
            
            menu.setMenuVisible(true, animated: true)
        }
        else
        {
            //Hide the menu if no line is selected
            menu.setMenuVisible(false, animated: true)
        }
        
        setNeedsDisplay()
    }
    
    func longPress(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        print("Recognized a longpress")
        
        if gestureRecognizer.state == .began
        {
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLineAtPoint(point: point)
            
            if selectedLineIndex != nil
            {
                currentLines.removeAll(keepingCapacity: false)
            }
        }
        else if gestureRecognizer.state == .ended
        {
            selectedLineIndex = nil
        }
        
        setNeedsDisplay()
    }
    
    func moveLine(_ gestureRecognizer: UIPanGestureRecognizer)
    {
        print("Recognized a pan gesture")
        
        //If a line is selected:
        if let index = selectedLineIndex
        {
            moveRecognizer.cancelsTouchesInView = true
            UIMenuController.shared.setMenuVisible(false, animated: true)
            
            //When the pan recognizer changes its position:
            if gestureRecognizer.state == .changed
            {
                //How far the pan has moved:
                let translation = gestureRecognizer.translation(in: self)
                
                //Add the translation to the current beginning and end points of the line
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                setNeedsDisplay()
            }
            else if gestureRecognizer.state == .ended
            {
                setMenuLocation(selectedLine: finishedLines[index])
            }
        }
        else
        {
            moveRecognizer.cancelsTouchesInView = false
            return
        }
    }
    
    func indexOfLineAtPoint(point:CGPoint) -> Int?
    {
        //Find a line close to point
        for (index, line) in finishedLines.enumerated()
        {
            let begin = line.begin
            let end = line.end
            
            //Check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05)
            {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                //If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0
                {
                    return index
                }
            }
        }
        
        //If users aren't fucking tapping a line, just return nothing
        return nil
    }
    
    func deleteLine(_ sender: AnyObject)
    {
        //Remove the selected line from the list of finishedLines
        if let index = selectedLineIndex
        {
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            //Redraw everything
            setNeedsDisplay()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func setMenuLocation(selectedLine: Line)
    {
        let menu = UIMenuController.shared
        
        if selectedLine.begin.y <= selectedLine.end.y && selectedLine.begin.y >= 0
        {
            menu.setTargetRect(CGRect(x: selectedLine.begin.x, y: selectedLine.begin.y, width: 2, height: 2), in: self)
            print(selectedLine.begin.y)
            print(selectedLine.end.y)
        }
        else
        {
            menu.setTargetRect(CGRect(x: selectedLine.end.x, y: selectedLine.end.y, width: 2, height: 2), in: self)
        }
        
        if menu.isMenuVisible == false
        {
            menu.setMenuVisible(true, animated: true)
        }
    }

}
