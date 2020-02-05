# Introduction
As we all know, Google Analytics is a perfect solution for user-data analytics. Unfortunately, there's no official SDK for macOS. Furthermore, with the recent deprecation of <a href="https://fabric.io/">Fabric.io</a>'s Crashlytics for Mac – alongside the forced migration to <a href="https://firebase.google.com/">Firebase</a> – Google has decided to drop macOS support from Fabric's acquisition altogether.

Still yet, there are several ways of using Google Analytics with macOS projects. MacGoogleAnalytics may be the solution that you've been looking for.

# Summary

Overall, there are 2 parts of the project that work together to use Google Analytics.

- HTML File
  - Located on a public server, this file uses Google Analytics' standard JavaScript API to send events received from the macOS app to your Google Analytics view.

- macOS Project
  - The macOS side of this project loads the HTML file previously mentioned and then uses it to send data (such as events, device info, date, etc.) through the JavaScript API.

# HTML File
You can find the HTML file in `html > gapp.html`.

## Parameters of the HTML File
The parameters of the HTML file are the exact same as with the normal Google Analytics HTML file.

```html
/gapp.html?param1=paramValue1&param2=paramValue2&...
```

Demo of the HTML file with full parameters:

```html
/gapp.html?id=UA-12345678-1&name=ihosts&version=1.1.0&ca=menu&ev=click&la=rate
```

Here is a list of the supported parameters:

- `id`
  - The Google Analytics id, eg. `UA-12345678-1`
  - **Note**: When creating a Google Analytics id, be sure to use **Apps** and not Web.
  
<img src="https://i.imgur.com/fhvgy01.png" width="860" />

<sup>I have not tested this with "Apps and web" yet.</sup>

- `name`
  - The product name, eg. `ihosts` for [iHosts](http://ex.toolinbox.net/ga/url.html?utm_medium=ihosts&utm_source=GitHub&id=UA-26569268-10&url=https%3a%2f%2fitunes.apple.com%2fapp%2fid1102004240%3fls%3d1%26mt%3d12). You can track different products using the same Google Analytics id; however, this is highly discouraged. 
- `version`
  - The app's version number, eg. `1.2.1` (use your app's CFBundleShortVersionString) 
- `ca` (*optional*)
  - The Google Analytics event category name.
- `ev` (*optional*)
  - The Google Analytics event action name.
- `la` (*optional*)
  - The Google Analytics event label value.

**Note**: The full URL's parameters will be encoded, so no need to worry about if the characters are valid or not.

## Deploy the HTML File
The HTML file should be deployed to a domain where it can be accessed via HTTPS protocal. I deployed it to a GitHub domain. Feel free to use it:

```html
http://atjason.com/MacGoogleAnalytics/gapp.html
```

Again, the file can be deployed to your own server with your own domain name.

**Tip**: You may want to reduce the HTML file size by compressing the JavaScript code it contains. Thus, your macOS app will be able to call it faster (albeit, by milliseconds).

# macOS Project
There's only 2 files needed for your macOS project: `GoogleAnalytics.swift` and `GoogleAnalyticsHelper.swift`.

## GoogleAnalytics.swift
Good news, you won't even need to touch this file.

This is the key-values file to integrate with Google Analytics. It will load the server-side HTML file into a temporary WebView and combine the data (event calls) sent from your macOS app with the parameters needed for Google Analytics API.

## GoogleAnalyticsHelper.swift
This is essentially your setup class for Google Analytics.

You'll only need to update these properties:

- `GAID`
  - The Google Analytics id, eg. `UA-12345678-1` (this is the 'id' used as a parameter of HTML file)
- `GAName`
  - The product name, eg. `ihosts` (this is the 'name' used as a parameter of HTML file)
- `PingURL`
  - The full URL of gapp.html, eg. `http://atjason.com/MacGoogleAnalytics/gapp.html` (or the URL of your own self-deployment)
- `PingTimeInterval`
  - By default, it's 6 hours. It tells Google Analytics, "Hey, I'm still alive!" every 6h. This will help Google Analytics to calculate the active users on your app.

# How to Integrate MacGoogleAnalytics
Use the MacGoogleAnalyticsSwiftDemo project for reference.

### Step 1
Import `GoogleAnalytics.swift` and `GoogleAnalyticsHelper.swift` (be sure to have "copy items" selected)

### Step 2
Have Google Analytics start when the app is launched and stop when the app will terminate.

**AppDelegate.swift**
```swift
func applicationDidFinishLaunching(_ aNotification: Notification) {   
    GAHelper.startGoogleAnalytics()
}

func applicationWillTerminate(_ aNotification: Notification) {
    GAHelper.stopGoogleAnalytics()
}
```
Some Ideas
- Set a UserDefault for detecting the first launch of new users
- Keep an error log and have it sent before the app is terminated
- Setup didLaunch and didTerminate events for both functions

### Step 3
The main usage for Google Analytics is to send event data. Sending event data can be done with even less code than Fabric:

```swift
GA.sendEvent(category: "menu", event: "click", label: "rate")
```

That's all, folks!

## Working With HTTP
When running your project with MacGoogleAnalytics, you may encounter this error:

*App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.*

This is likely due to the HTML file being on a server without proper SSL certificates. For security reasons, it's recommended that you use a domain with HTTPS (ie. https://your-site.com/gapp.html).

If you really need to enable functionality for your HTTP site, open `Info.plist` and add the following lines:

```swift
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

Please keep in mind that this solution should be a last resort. More info on [AppTransportSecurity](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity) can be found on the [Apple Developer Documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity).

# Viewing Data in Google Analytics
After data is collected from your macOS app, you can view them in Google Analytics as normal: [https://analytics.google.com/analytics/web/](https://analytics.google.com/analytics/web/). During the debugging process, you can also check whether it works or not in the **Real-Time** section of GA.

**Detecting macOS Versions**

In the Swift Demo app, it collects the event data of `options > option_a > yes or no`. Let's say that you want to know how many users that triggered this event are running macOS 10.14 and how many are running 10.15. How would you go about doing this?

Trick question, it's done for you – you just need to filter it.

1. Go to [Google Analytics](https://analytics.google.com/analytics/web/)
2. Open `Behavior > Events > Top Events`
3. Select `options > option_a` (here you should be able to see all of the events)
4. Click add `+ Custom Segment`
5. In `Technology > Operating System Version`, add *contains* '10.14' and save it as `macOS 10.14`
6. Add another Custom Segment for `macOS 10.15`, etc.
7. Repeat for all the macOS versions that your app supports

<img src="https://i.imgur.com/De1Kdkz.png" width="860" />

Once you've applied these Custom Segments, you should be able to distinguish the data between macOS 10.14 and 10.15.

# Releasing on the Mac App Store
Yes, Google Analytics are allowed on the Mac App Store. Here are some apps that have already been released on the Mac App Store using MacGoogleAnalytics:

- [iHosts](http://ex.toolinbox.net/ga/url.html?utm_medium=ihosts&utm_source=GitHub&id=UA-26569268-10&url=https%3a%2f%2fitunes.apple.com%2fapp%2fid1102004240%3fls%3d1%26mt%3d12)
- [Daily Clipboard](http://ex.toolinbox.net/ga/url.html?utm_medium=clip&utm_source=GitHub&id=UA-26569268-10&url=https%3a%2f%2fitunes.apple.com%2fapp%2fid1056935452%3fls%3d1%26mt%3d12)
- [Attention Timer](http://ex.toolinbox.net/ga/url.html?utm_medium=timer&utm_source=GitHub&id=UA-26569268-10&url=https%3a%2f%2fitunes.apple.com%2fapp%2fid1062139745%3fls%3d1%26mt%3d12)

Be sure to make your users aware that you are using Google Analytics!

# License
MacGoogleAnalytics is licensed under the terms of the MIT license. Feel free to use it! :)

# Donate
If you think that MacGoogleAnalytics was helpful, you are welcome to [donate](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=quietjason%40gmail%2ecom&lc=US&item_name=Mac%20Google%20Analytics&button_subtype=services&currency_code=USD&bn=PP%2dBuyNowBF%3abtn_buynow_SM%2egif%3aNonHosted).
