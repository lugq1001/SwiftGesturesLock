//
//  ViewController.swift
//  SwiftGesturesLock
//
//  Created by luguangqing on 15/11/3.
//  Copyright © 2015年 luguangqing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var gesturesView: GesturesLockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRectMake(0, 64, 320, 320);
        gesturesView = GesturesLockView(frame: frame)
        view.addSubview(gesturesView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

