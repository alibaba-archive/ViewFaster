//
//  ViewFaster.swift
//  ViewFaster
//
//  Created by ChenHao on 5/23/16.
//  Copyright © 2016 HarriesChen. All rights reserved.
//

import Foundation
import SpriteKit

open class ViewFaster: NSObject {

    open static var shareInstance: ViewFaster = ViewFaster()

    static let kFPSLabelWidth = 60
    static let kHardwareFramesPerSecond = 60
    var lastSecondOfFrameTimes = [CFTimeInterval]()
    var frameNumber = 0

    open var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                enableFPS()
            } else {
                disableFPS()
            }
        }
    }

    var isRunning: Bool = false {
        didSet {
            if isRunning {
                start()
            } else {
                stop()
            }
        }
    }

    override init() {
        for _ in 0...ViewFaster.kHardwareFramesPerSecond {
            lastSecondOfFrameTimes.append(CACurrentMediaTime())
        }
    }

    lazy var window: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = UIWindowLevelStatusBar + 10.0
        window.isUserInteractionEnabled = false

        return window
    }()

    lazy var FPSLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: kFPSLabelWidth, height: 20))
        label.backgroundColor = UIColor.red
        label.textAlignment = .center
        return label
    }()

    func enableFPS() {
        window.addSubview(FPSLabel)
        window.isHidden = false
        isRunning = true
    }

    func disableFPS() {
        FPSLabel.removeFromSuperview()
        window.isHidden = true
        isRunning = false
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

        recordFrameTime(currentFrameTime)
        updateFPSLabel()
    }

    func lastFrameTime() -> CFTimeInterval {
        if frameNumber <= ViewFaster.kHardwareFramesPerSecond {
            return lastSecondOfFrameTimes[self.frameNumber]
        } else {
            return CACurrentMediaTime()
        }
    }

    func recordFrameTime(_ timeInterval: CFTimeInterval) {
        frameNumber += 1
        lastSecondOfFrameTimes[frameNumber % ViewFaster.kHardwareFramesPerSecond] = timeInterval
    }

    func updateFPSLabel() {
        let fps = ViewFaster.kHardwareFramesPerSecond - droppedFrameCountInLastSecond()

        if fps >= 56 {
            FPSLabel.backgroundColor = UIColor.green
        } else if fps >= 45 {
            FPSLabel.backgroundColor = UIColor.orange
        } else {
            FPSLabel.backgroundColor = UIColor.red
        }
        FPSLabel.text = "\(fps)"
    }

    func start() {
        self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        clearLastSecondOfFrameTimes()

        let scene = SKScene()
        sceneView.presentScene(scene)
        UIApplication.shared.keyWindow?.addSubview(sceneView)
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
            if 1.0 <= lastFrameTime - lastSecondOfFrameTimes[i] {
                droppedFrameCount += 1
            }
        }
        return droppedFrameCount
    }
}
