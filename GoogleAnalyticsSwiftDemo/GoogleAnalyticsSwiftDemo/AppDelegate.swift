//
//  AppDelegate.swift
//  GoogleAnalyticsSwiftDemo
//
//  Created by Jason Zheng on 5/13/16.
//  Copyright © 2016 Jason Zheng. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainWindowController: MainWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainWindowController = MainWindowController()
        mainWindowController.showWindow(self)
        
        self.mainWindowController = mainWindowController
        
        GAHelper.startGoogleAnalytics()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        GAHelper.stopGoogleAnalytics()
    }
}

