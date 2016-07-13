//
//  AppDelegate.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var baseViewController: ViewController = ViewController()
    var baseNavViewController: UINavigationController = UINavigationController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.baseNavViewController.view.backgroundColor = UIColor.white()
        baseNavViewController.setNavigationBarHidden(true, animated: false)
        window = UIWindow(frame: UIScreen.main().bounds)
        baseNavViewController.pushViewController(baseViewController, animated: false)
        window?.rootViewController = self.baseNavViewController
        window?.makeKeyAndVisible()
        return true
    }
}


