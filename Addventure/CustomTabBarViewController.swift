//
//  CustomTabBarViewController.swift
//  addventure
//
//  Created by Christian  on 3/21/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import Foundation
import UIKit


class CustomTabBarViewController: UITabBarController, CustomTabBarDataSource, CustomTabBarDelegate
 {
    func tabBarItemsInCustomTabBar(_ tabBarView: CustomTabBar) -> [UITabBarItem] {
        return tabBar.items!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tabBar.isHidden = true
        self.selectedIndex = 1
     
        let customTabBar = CustomTabBar(frame: self.tabBar.frame)
 
        self.view.addSubview(customTabBar)
        
        customTabBar.datasource = self
        
        customTabBar.setup()
        customTabBar.delegate = self
        
    }
    func didSelectViewController(_ tabBarView: CustomTabBar, atIndex index: Int) {
        self.selectedIndex = index
    }
}
