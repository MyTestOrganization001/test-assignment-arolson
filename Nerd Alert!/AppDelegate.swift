//
//  AppDelegate.swift
//  Nerd Alert!
//
//  Created by Andrew Olson on 11/15/16.
//  Copyright © 2016 Valhalla Applications. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let googleAuth = FIRAuthUI.default()?.handleOpen(url, sourceApplication: sourceApplication ?? "") ?? false
        let facebookAuth = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) 
       
        if googleAuth || facebookAuth
        {
            return true
        }
        else
        {
            return false
        }
    }


}

