//
//  ViewFaster.swift
//  ViewFaster
//
//  Created by ChenHao on 5/23/16.
//  Copyright © 2016 HarriesChen. All rights reserved.
//

import Foundation
import SpriteKit

public class ViewFaster: NSObject {
    
    public static var shareInstance: ViewFaster = ViewFaster()
    
    static let kHardwareFramesPerSecond = 60
    
    var _lastSecondOfFrameTimes = [CFTimeInterval]()
    
    var frameNumber = 0
    
    static let kFPSLabelWidth = 60
    
    public var enable: Bool = false {
        didSet {
            if enable {
                _enable()
            } else {
                _disable()
            }
        }
    }
    
    var running: Bool = false {
        didSet {
            if running {
                start()
            } else {
                stop()
            }
        }
        
    }
    
    override init() {
        for _ in 0...ViewFaster.kHardwareFramesPerSecond {
            _lastSecondOfFrameTimes.append(CACurrentMediaTime())
        }
    }
    
    lazy var window: UIWindow = {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = UIWindowLevelStatusBar + 10.0
        window.userInteractionEnabled = false
        
        return window
    }()
    
    lazy var FPSLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: kFPSLabelWidth, height: 20))
        label.backgroundColor = UIColor.redColor()
        label.textAlignment = .Center
        return label
    }()
    
    func _enable() {
        window.addSubview(FPSLabel)
        window.hidden = false
        running = true
    }
    
    func _disable() {
        
        FPSLabel.removeFromSuperview()
        window.hidden = true
        running = false
    }
    
    lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkWillDraw))
        return displayLink
    }()
    
    lazy var sceneView: SKView = {
        let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        return sceneView
    }()
    
    func displayLinkWillDraw() {
        let currentFrameTime = displayLink.timestamp
//        let frameDuartion = currentFrameTime - lastFrameTime()
    
        recordFrameTime(currentFrameTime)
        updateFPSLabel()
    }
    
    func lastFrameTime() -> CFTimeInterval{
        if frameNumber <= ViewFaster.kHardwareFramesPerSecond {
            return _lastSecondOfFrameTimes[self.frameNumber]
        } else {
            return CACurrentMediaTime()
        }
    }
    
    func recordFrameTime(timeInterval: CFTimeInterval) {
        frameNumber += 1
        _lastSecondOfFrameTimes[self.frameNumber % ViewFaster.kHardwareFramesPerSecond] = timeInterval;
    }
    
    func updateFPSLabel() {
        
        let fps = ViewFaster.kHardwareFramesPerSecond - droppedFrameCountInLastSecond()
        
        if fps >= 56 {
            FPSLabel.backgroundColor = UIColor.greenColor()
        } else if fps >= 45 {
            FPSLabel.backgroundColor = UIColor.orangeColor()
        } else {
            FPSLabel.backgroundColor = UIColor.redColor()
        }
        
        FPSLabel.text = "\(fps)"
    }
    
    func start() {
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        clearLastSecondOfFrameTimes()
        
        // Low framerates can be caused by CPU activity on the main thread or by long compositing time in (I suppose)
        // the graphics driver. If compositing time is the problem, and it doesn't require on any main thread activity
        // between frames, then the framerate can drop without CADisplayLink detecting it.
        // Therefore, put an empty 1pt x 1pt SKView in the window. It shouldn't interfere with the framerate, but
        // should cause the CADisplayLink callbacks to match the timing of drawing.
        
        let scene = SKScene()
        sceneView.presentScene(scene)
        UIApplication.sharedApplication().keyWindow?.addSubview(sceneView)
    }
    
    func stop() {
        sceneView.removeFromSuperview()
        self.displayLink.invalidate()
    }
    
    func clearLastSecondOfFrameTimes() {
        
    }
    
    func droppedFrameCountInLastSecond() -> Int {
        var droppedFrameCount = 0
        
        let kNormalFrameDuration = 1.0 / Double(ViewFaster.kHardwareFramesPerSecond)
        let lastFrameTime = CACurrentMediaTime() - kNormalFrameDuration
        for i in 0..<ViewFaster.kHardwareFramesPerSecond {
            if 1.0 <= lastFrameTime - _lastSecondOfFrameTimes[i] {
                droppedFrameCount += 1
            }
        }
        return droppedFrameCount
        
    }
}