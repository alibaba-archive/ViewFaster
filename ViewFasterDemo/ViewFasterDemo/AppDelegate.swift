//
//  AppDelegate.swift
//  ViewFasterDemo
//
//  Created by ChenHao on 5/23/16.
//  Copyright © 2016 HarriesChen. All rights reserved.
//

import UIKit

// swiftlint:disable line_length

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKey()


        return true
    }
}
