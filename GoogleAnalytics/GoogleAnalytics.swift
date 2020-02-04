//
//  GoogleAnalytics.swift
//  Test
//
//  Created by Jason Zheng on 11/27/15.
//  Copyright © 2015 Jason Zheng. All rights reserved.
//

import Cocoa
import WebKit

let GA = GoogleAnalytics.sharedInstance

class GoogleAnalytics: NSObject {
    
    static let sharedInstance = GoogleAnalytics()
    private override init() { super.init() }
    
    private var webViews = Set<WebView>()
    private let timeIntervalDelayToRemoveWebView = TimeInterval(10)
    private weak var timer: Timer?
    
    var yes = "yes"
    var no = "no"
    var none = "none"
    
    private var pingURL = ""
    private let userUUIDKey = "User UUID"
    private let paramCategory = "ca"
    private let paramEvent = "ev"
    private let paramLabel = "la"
    
    func setPingURL(url: String) {
        pingURL = url
    }
    
    func startPing(timeInternal: TimeInterval) {
        if timer == nil {
            timer = Timer.scheduledTimer(
                timeInterval: timeInternal, target: self, selector: #selector(GoogleAnalytics.doPing),
                userInfo: nil, repeats: true)
            timer?.tolerance = timeInternal * 0.1
        }
        
        timer?.fire()
    }
    
    func stopPing() {
        timer?.invalidate()
    }
    
    @objc func doPing() {
        GA.sendEvent(category: "app", event: "ping", label: GAHelper.getAppVersion())
    }
    
    @objc func doPingURL(url: String) {
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        if encodedURL != nil {
            if let requestURL = NSURL(string: encodedURL!) {
                DispatchQueue.global(qos: .background).async {
                    // Background Thread
                    
                    DispatchQueue.main.async {
                        // Run UI Updates
                        let newWebView = WebView()
                        self.webViews.insert(newWebView)
                        newWebView.frameLoadDelegate = self
                        
                        let request = NSURLRequest(url: requestURL as URL)
                        newWebView.mainFrame.load(request as URLRequest)
                    }
                }
            } else {
                NSLog("Failed to generate NSURL from \(url)")
            }
        } else {
            NSLog("Failed to encode URL from \(url)")
        }
    }
    
    func sendEvent(category: String, event: String?, label: String?) {
        var url = pingURL
        
        if !category.isEmpty {
            if !url.contains("?") {
                url += "?"
            } else {
                url += "&"
            }
            
            url += "\(paramCategory)=\(category)"
            
            if (event != nil) && (!event!.isEmpty) {
                url += "&\(paramEvent)=\(event!)"
                
                if (label != nil) && (!label!.isEmpty) {
                    url += "&\(paramLabel)=\(label!)"
                }
            }
        }
        
        //self.performSelector(inBackground: #selector(GoogleAnalytics.doPingURL(_:)), with: url)
        self.performSelector(inBackground: #selector(GoogleAnalytics.doPingURL(url:)), with: url)
    }
    
    func initUUIDIfNeeded() {
        let userDefaults = UserDefaults.standard
        let userUUID = userDefaults.value(forKey: userUUIDKey) as? String
        
        if userUUID == nil {
            userDefaults.setValue(NSUUID().uuidString, forKey: userUUIDKey)
            let localeID = NSLocale.current.identifier
            
            //let locale = NSLocale.currentLocale.objectForKey(NSLocaleIdentifier) as? String ?? ""
            let locale = NSLocale.init(localeIdentifier: localeID).object(forKey: NSLocale.Key(rawValue: localeID)) ?? ""
            let os = GAHelper.getOSXVersion()
            let version = GAHelper.getAppVersion()
            let info = "\(locale)_\(os)_\(version)"
            GA.sendEvent(category: "app", event: "init", label: info)
        }
    }
}

extension GoogleAnalytics: WebFrameLoadDelegate {
    
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        self.perform(#selector(GoogleAnalytics.removeUnusedWebView(webView:)), with: sender, afterDelay: timeIntervalDelayToRemoveWebView)
        //self.performSelector(#selector(GoogleAnalytics.removeUnusedWebView(_:)), withObject: sender, afterDelay: timeIntervalDelayToRemoveWebView)
        //self.perform(#selector(GoogleAnalytics.removeUnusedWebView(_:)), with: sender, afterDelay: timeIntervalDelayToRemoveWebView)
    }
    
    @objc func removeUnusedWebView(webView: WebView) {
        webView.close()
        self.webViews.remove(webView)
    }
}
