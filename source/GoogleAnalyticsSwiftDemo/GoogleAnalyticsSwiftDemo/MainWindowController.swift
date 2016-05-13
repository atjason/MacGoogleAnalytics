//
//  MainWindowController.swift
//  GoogleAnalyticsSwiftDemo
//
//  Created by Jason Zheng on 5/13/16.
//  Copyright © 2016 Jason Zheng. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
  
  @IBOutlet weak var optionA: NSButton!
  
  override var windowNibName: String? {
    return "MainWindowController"
  }
  
  @IBAction func sendEvent(sender: NSButton!) {
    let selected = (optionA.state == NSOnState)
    let label = selected ? GA.yes : GA.no
    GA.sendEvent("options", event: "option_a", label: label)
  }
}

