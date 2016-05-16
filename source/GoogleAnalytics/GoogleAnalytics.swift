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
  private let timeIntervalDelayToRemoveWebView = NSTimeInterval(10)
  private weak var timer: NSTimer?
  
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
  
  func startPing(timeInternal: NSTimeInterval) {
    if timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(
        timeInternal, target: self, selector: #selector(GoogleAnalytics.doPing),
        userInfo: nil, repeats: true)
      timer?.tolerance = timeInternal * 0.1
    }
    
    timer?.fire()
  }
  
  func stopPing() {
    timer?.invalidate()
  }
  
  func doPing() {
    GA.sendEvent("app", event: "ping", label: GAHelper.getAppVersion())
  }
  
  func doPingURL(url: String) {
    
    let encodedURL = url.stringByAddingPercentEncodingWithAllowedCharacters(
      NSCharacterSet.URLQueryAllowedCharacterSet())
    
    if encodedURL != nil {
      if let requestURL = NSURL(string: encodedURL!) {
        dispatch_async(dispatch_get_main_queue(), {
          let newWebView = WebView()
          self.webViews.insert(newWebView)
          newWebView.frameLoadDelegate = self
          
          let request = NSURLRequest(URL: requestURL)
          newWebView.mainFrame.loadRequest(request)
        })
        
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
      if !url.containsString("?") {
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
    
    self.performSelector(#selector(GoogleAnalytics.doPingURL(_:)), withObject: url)
  }
  
  func initUUIDIfNeeded() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let userUUID = userDefaults.valueForKey(userUUIDKey) as? String
    
    if userUUID == nil {
      userDefaults.setValue(NSUUID().UUIDString, forKey: userUUIDKey)
      
      let locale = NSLocale.currentLocale().objectForKey(NSLocaleIdentifier) as? String ?? ""
      let os = GAHelper.getOSXVersion()
      let version = GAHelper.getAppVersion()
      let info = "\(locale)_\(os)_\(version)"
      GA.sendEvent("app", event: "init", label: info)
    }
  }
}

extension GoogleAnalytics: WebFrameLoadDelegate {
  
  func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
    self.performSelector(#selector(GoogleAnalytics.removeUnusedWebView(_:)),
                         withObject: sender,
                         afterDelay: timeIntervalDelayToRemoveWebView)
  }
  
  func removeUnusedWebView(webView: WebView) {
    webView.close()
    self.webViews.remove(webView)
  }
}
