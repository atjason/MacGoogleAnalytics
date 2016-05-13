//
//  GoogleAnalytics.swift
//  Test
//
//  Created by Jason Zheng on 11/27/15.
//  Copyright © 2015 Jason Zheng. All rights reserved.
//

import WebKit
import Cocoa

let GA = GoogleAnalytics.sharedInstance

class GoogleAnalytics: NSObject {
  
  static let sharedInstance = GoogleAnalytics()
  
  private override init() { super.init() }
  
  private var pingURL = ""
  
  private var webViews = Set<WebView>()
  private let timeIntervalDelayToRemoveWebView = NSTimeInterval(60)
  
  private weak var timer: NSTimer?
  
  var yes = "yes"
  var no = "no"
  var none = "none"
  
  private let paramCategory = "ca"
  private let paramEvent = "ev"
  private let paramLabel = "la"
  
  func setPingURL(url: String) {
    pingURL = url
  }
  
  func startPing(timeInternal: NSTimeInterval) {
    if timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(timeInternal,
                                                     target: self, selector: #selector(GoogleAnalytics.doPing),
                                                     userInfo: nil, repeats: true)
      timer?.tolerance = timeInternal * 0.01
    }
    
    timer?.fire()
  }
  
  func stopPing() {
    timer?.invalidate()
  }
  
  func pingOnce() {
    self.performSelector(#selector(GoogleAnalytics.doPing), withObject: self)
  }
  
  func doPing() {
    GA.sendEvent("app", event: "ping", label: Utilities.getAppVersion())
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
        
        //NSLog(url)
        
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
  
  func initUUIDIfNeeded(uuidKey: String) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let userUUID = userDefaults.valueForKey(uuidKey) as? String
    
    if userUUID == nil {
      let uuid = NSUUID().UUIDString
      userDefaults.setValue(uuid, forKey: uuidKey)
      
      let locale = NSLocale.currentLocale()
      
      // Version
      let version = Utilities.getAppVersion()
      GA.sendEvent("init", event: "version", label: version)
      
      // OS
      let os = Utilities.getOSXVersion()
      GA.sendEvent("init", event: "os", label: os)
      
      // Language
      let language = NSLocale.preferredLanguages().count > 0 ? NSLocale.preferredLanguages()[0] : ""
      GA.sendEvent("init", event: "language", label: language)
      
      // Country
      let country = locale.objectForKey(NSLocaleCountryCode) as? String ?? ""
      GA.sendEvent("init", event: "country", label: country)
      
      // All
      let formatter = NSDateFormatter()
      formatter.dateFormat = "yyyy-MM-dd_HH:mm"
      let timeZone = NSTimeZone.localTimeZone().localizedName(NSTimeZoneNameStyle.ShortStandard, locale: nil) ?? ""
      let dateString = formatter.stringFromDate(NSDate()) + "_" + timeZone
      
      let localeIdentifier = locale.objectForKey(NSLocaleIdentifier) as? String ?? ""
      let all = "\(localeIdentifier)_\(os)_\(dateString)_\(version)"
      GA.sendEvent("init", event: "all", label: all)
    }
  }
}

extension GoogleAnalytics: WebFrameLoadDelegate {
  
  func removeUnusedWebView(webView: WebView) {
    webView.close()
    self.webViews.remove(webView)
  }
  
  func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
    // Should remove in method of "willPerformClientRedirectToURL"
    // This is just to avoid memory leak if the way can't work.
    self.performSelector(#selector(GoogleAnalytics.removeUnusedWebView(_:)), withObject: sender, afterDelay: timeIntervalDelayToRemoveWebView)
  }
  
  func webView(sender: WebView!, willPerformClientRedirectToURL URL: NSURL!, delay seconds: NSTimeInterval, fireDate date: NSDate!, forFrame frame: WebFrame!) {
    // Why use this delegate? As it needs time to run the Google Analytics script after the html file was downloaded.
    // But there's no method to get this time point. Thus add URL redirect in the html file.
    // And monitor this URL redirect to know the script has run.
    // TODO: Improve this method. Remove the unneeded code in site.
    
    // Remove the reference of this WebView to release it
    removeUnusedWebView(sender)
  }
}
