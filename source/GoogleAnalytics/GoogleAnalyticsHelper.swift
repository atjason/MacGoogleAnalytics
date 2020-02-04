//
//  GoogleAnalytics.swift
//  Test
//
//  Created by Jason Zheng on 11/27/15.
//  Copyright © 2015 Jason Zheng. All rights reserved.
//

import Foundation

typealias GAHelper = GoogleAnalyticsHelper

class GoogleAnalyticsHelper {
    
    static let GAID = "UA-76794534-4"
    static let GAName = "Demo"
    static let PingURL = "http://atjason.com/MacGoogleAnalytics/gapp.html?id=\(GAID)&name=\(GAName)&version=\(GoogleAnalyticsHelper.getAppVersion())"
    static let PingTimeInterval: TimeInterval = 3600 * 6 // Ping every 6h
    
    // MARK: - Helper
    
    static func startGoogleAnalytics() {
        GA.setPingURL(url: PingURL)
        
        GA.startPing(timeInternal: PingTimeInterval)
        GA.sendEvent(category: "app", event: "start", label: getAppVersion())
        GA.initUUIDIfNeeded()
    }
    
    static func stopGoogleAnalytics() {
        GA.stopPing()
    }
    
    static func getAppVersion() -> String {
        let versionObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = versionObject as? String ?? "0.0.0"
        
        return version
    }
    
    static func getOSXVersion() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return versionString
    }
}
