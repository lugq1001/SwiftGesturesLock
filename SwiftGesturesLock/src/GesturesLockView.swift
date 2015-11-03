//
//  GesturesLockView.swift
//  SwiftGesturesLock
//
//  Created by luguangqing on 15/11/3.
//  Copyright © 2015年 luguangqing. All rights reserved.
//

import UIKit

enum MNGesturesState {
    case Normal, Error
}

protocol GesturesLockDelegate {
    func gesturesLockDrawPasswordCompleted(gesturePassword: String)
}

class GesturesLockView: UIView {
    
    let kDefaultDiameters: CGFloat = 80.0
    
    private var points: [GesturesLockPoint] = []
    private var defaultPointImage = UIImage(named: "MNGesturesPointNormal")
    private var touchedPointImage = UIImage(named: "MNGesturesPointTouched")
    private var errorPointImage = UIImage(named: "MNGesturesPointError")
    var ref: CGContextRef?
    var lineX: CGFloat = CGFloat.min
    var lineY: CGFloat = CGFloat.min
    var state = MNGesturesState.Normal
    
    var touchedColor = UIColor(red: 1.0, green: 0.84, blue: 0.37, alpha: 0.65)
    var errorColor = UIColor(red: 1.0, green: 0.37, blue: 0.1, alpha: 0.65)
    
    var delegate: GesturesLockDelegate?
    var password: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup() {
        backgroundColor = UIColor.clearColor()
        
        self.points = []
        var diameters: CGFloat?
        if (self.defaultPointImage != nil) {
            diameters = self.defaultPointImage!.size.width
        } else {
            diameters = kDefaultDiameters
        }
        let spacing = (self.bounds.size.width - diameters! * 3) / 4
        var startX = spacing
        var startY: CGFloat = 0
        for i in 0..<9 {
            if(i == 3 || i == 6) {
                startX = spacing
                startY += diameters! + spacing
            }
            let point = GesturesLockPoint.create(i, x: startX, y: startY, diameters: diameters!)
            points.append(point)
            startX += diameters! + spacing
        }
        
    }
    
    override func drawRect(rect: CGRect) {
        let ref = UIGraphicsGetCurrentContext()
        CGContextSetShouldAntialias(ref, true)
        CGContextSetLineWidth(ref, 10)
        var color = touchedColor.CGColor
        if(state == .Error) {
            color = errorColor.CGColor
        }
        let components = CGColorGetComponents(color)
        CGContextSetRGBStrokeColor(ref, components[0], components[1], components[2], components[3])
        self.ref = ref
        drawSelf()
    }
    
    private func drawSelf() {
        if !password.isEmpty {
            let startPointId = Int(String2NSString(password).characterAtIndex(0)) - 48
            var start = points[startPointId]
            while start.hasNextPosition() {
                let next = points[start.nextPosition]
                drawLine(start.getCenterX(), startY: start.getCenterY(), endX: next.getCenterX(), endY: next.getCenterY())
                start = next
            }
            if lineX != CGFloat.min && lineY != CGFloat.min {
                drawLine(start.getCenterX(), startY: start.getCenterY(), endX: lineX, endY: lineY)
            }
        }
        for p in points {
            defaultPointImage?.drawAtPoint(CGPointMake(p.x, p.y))
            if p.touchSuccess {
                touchedPointImage?.drawAtPoint(CGPointMake(p.x, p.y))
            } else if p.touchError {
                errorPointImage?.drawAtPoint(CGPointMake(p.x, p.y))
            }
        }
    }
    
    private func drawLine(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) {
        CGContextMoveToPoint(self.ref, startX, startY)
        CGContextAddLineToPoint(self.ref, endX, endY)
        CGContextStrokePath(self.ref)
    }
    
    private func resetPoints() {
        for p in points {
            p.touchSuccess = false
            p.touchError = false
            p.nextPosition = p.position
        }
        lineX = CGFloat.min
        lineY = CGFloat.min
        state = .Normal
    }
    
    
    // MARK: - Touches
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        password = ""
        if let point = touches.first?.locationInView(self) {
            var inRange = false
            for p in points {
                if p.isInRange(point.x, y: point.y) {
                    p.touchSuccess = true
                    password += "\(p.position)"
                    inRange = true
                    break
                }
            }
            if !inRange {
                return
            }
        }
        setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let point = touches.first?.locationInView(self) {
            lineX = point.x
            lineY = point.y
            for p in points {
                if p.isInRange(point.x, y: point.y) && !p.touchSuccess {
                    p.touchSuccess = true
                    if !password.isEmpty {
                        let preId = Int(String2NSString(password).characterAtIndex(password.characters.count - 1)) - 48
                        points[preId].nextPosition = p.position
                    }
                    password += "\(p.position)"
                    print(password)
                    break
                }
            }
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if password.isEmpty {
            return
        }
        resetPoints()
        setNeedsDisplay()
        delegate?.gesturesLockDrawPasswordCompleted(password)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
    }
    
    func drawPasswordError() {
        userInteractionEnabled = false
        state = .Error
        let length = password.characters.count
        for i in 0..<length {
            let position = Int(String2NSString(password).characterAtIndex(i)) - 48
            points[position].touchError = true
            if i + 1 < length {
                points[position].nextPosition = Int(String2NSString(password).characterAtIndex(password.characters.count + 1)) - 48
            }
        }
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "drawErrorCompleted:", userInfo: nil, repeats: false)
    }
    
    func drawErrorCompleted(timer: NSTimer) {
        resetPoints()
        setNeedsDisplay()
        userInteractionEnabled = true
    }
    
    func String2NSString(string: String) -> NSString {
        let s: NSString = NSString(CString: string.cStringUsingEncoding(NSUTF8StringEncoding)!,
            encoding: NSUTF8StringEncoding)!
        return s
    }
    
    
}


class GesturesLockPoint: NSObject {
    
    var position = 0
    var nextPosition = 0
    
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    var diameters: CGFloat = 0
    
    var touchSuccess = false
    var touchError = false
    
    class func create(position: Int, x: CGFloat, y: CGFloat, diameters: CGFloat) -> GesturesLockPoint {
        let point = GesturesLockPoint()
        point.position = position
        point.nextPosition = position
        point.x = x
        point.y = y
        point.diameters = diameters
        return point
    }
    
    func hasNextPosition() -> Bool {
        return nextPosition != position
    }
    
    func getCenterX() -> CGFloat {
        return x + self.diameters / 2
    }
    
    func getCenterY() -> CGFloat {
        return y + self.diameters / 2
    }
    
    func isInRange(x: CGFloat, y: CGFloat) -> Bool {
        let inX = x > self.x && x < (self.x + diameters)
        let inY = y > self.y && y < (self.y + diameters)
        return inX && inY
    }
    
    
}



























