//
//  ViewController.swift
//  ViewFasterDemo
//
//  Created by ChenHao on 5/23/16.
//  Copyright © 2016 HarriesChen. All rights reserved.
//

import UIKit
import ViewFaster

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func open(sender: AnyObject) {
        ViewFaster.shareInstance.enable = true
    }

    @IBAction func close(sender: AnyObject) {
        ViewFaster.shareInstance.enable = false
    }
}

