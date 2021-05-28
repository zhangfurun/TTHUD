//
//  AppDelegate.swift
//  TTHUD
//
//  Created by 张福润 on 2021/5/28.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let rect : CGRect = UIScreen.main.bounds
        
        self.window = UIWindow(frame:rect)
        
        let vc = ViewController()
        
        self.window?.rootViewController = vc
        
        self.window?.backgroundColor = .white
        
        self.window?.makeKeyAndVisible()
        return true
    }
}

