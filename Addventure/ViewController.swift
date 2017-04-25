//
//  ViewController.swift
//  addventure
//
//  Created by Christian  on 3/21/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.isHidden = true
        
        let customTabBar = CustomTabBar(frame: self.tabBar.frame)
        self.view.addSubview(customTabBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

