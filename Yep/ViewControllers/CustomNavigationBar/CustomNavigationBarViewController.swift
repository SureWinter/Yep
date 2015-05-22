//
//  CustomNavigationBarViewController.swift
//  Yep
//
//  Created by NIX on 15/5/8.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

class CustomNavigationBarViewController: UIViewController {


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = navigationController {
            
            navigationController.navigationBar.backgroundColor = UIColor.clearColor()
            navigationController.navigationBar.translucent = true
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
            navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)

            let textAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont.navigationBarTitleFont()
            ]

            navigationController.navigationBar.titleTextAttributes = textAttributes
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
        }
    }

//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        if let navigationController = navigationController {
//
//            navigationController.navigationBar.backgroundColor = nil
//            navigationController.navigationBar.translucent = true
//            navigationController.navigationBar.shadowImage = nil
//            navigationController.navigationBar.barStyle = UIBarStyle.Default
//            navigationController.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
//
//            let textAttributes = [
//                NSForegroundColorAttributeName: UIColor.yepTintColor(),
//                NSFontAttributeName: UIFont.navigationBarTitleFont()
//            ]
//
//            navigationController.navigationBar.titleTextAttributes = textAttributes
//            navigationController.navigationBar.tintColor = nil
//        }
//    }
}