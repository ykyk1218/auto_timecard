//
//  CustomNavigationControllerViewController.swift
//  auto_timecard
//
//  Created by 小林芳樹 on 2016/01/13.
//  Copyright © 2016年 小林芳樹. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    let lblNavTitle = UILabel()

    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationBar.barTintColor = UIColor.hex("b3d3ac", alpha: 1.0)
        //self.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.blackColor()]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
    }
}
