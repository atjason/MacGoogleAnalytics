**Note:**

For Swift 5, Xcode 11.3 & Catalina Support and updated README, please check the 'swift5' branch. Thanks [revblaze](https://github.com/revblaze)'s conribution.

Google Analytics for Mac OS X using Swift.


# Introduction
As we know, Google Analytics is perfect for user data collection and analytics. But unfortunately, there's no official SDK for Mac OS X.

But still, there're several ways to use Google Analytics on Mac OS X. MacGoogleAnalytics may be what you found.

Overall, there're 2 parts work together to use Google Analytics.

- HTML File
  - This is the real place to send data to Google Analytics server. It uses Google Analytics's standard JavaScript API.

- Mac OS X Part
  - In Mac OS X side, it loads the html file just mentioned. Send data like event to the html file as parameters. And then these data will be send in the html file through the JavaScript API.

# HTML File
You can find the html file in `source > html > gapp.html`.

## Parameter of HTML File
The parameter of the html file is exactly the same with normal html file.

```html
/gapp.html?param1=paramValue1&param2=paramValue2&...
```

Demo of the html file with full parameters:

```html
/gapp.html?id=UA-12345678-1&name=ihosts&version=1.1.0&ca=menu&ev=click&la=rate
```

Here are the supported parameter list.

- `id`
  - The Google Analytics id, e.g., 'UA-12345678-1'.
  - **Note**: When you create a Google Analytics id, use the '**Mobile app**', but not 'Website'.
  
![1759091](http://p.appsites.io/2016-05-14-1759091.jpg)

- `name`
  - The product name, e.g., 'ihosts' for [iHosts](http://ex.toolinbox.net/ga/url.html?utm_medium=ihosts&utm_source=GitHub&id=UA-26569268-10&url=https%3a%2f%2fitunes.apple.com%2fapp%2fid1102004240%3fls%3d1%26mt%3d12). You can track different products using same Google Analytics id, even I don't suggest you do that. 
- `version`
  - The app's version, e.g., '1.2.1'.
- `ca` (*optional*)
  - The Google Analytics event category name.
- `ev` (*optional*)
  - The Google Analytics event action name.
- `la` (*optional*)
  - The Google Analytics event label value.

**Note**: The full url include the parameters will be encoded. So no need to worry about the characters are valid or not. They will all be valid.

## Deploy the HTML File
The html file should be deployed to a domain before it can be accessed. I deployed it at GitHub with my domain, you can feel free to use it.

```html
http://atjason.com/MacGoogleAnalytics/gapp.html
```

You can also deploy it to your server with your domain.

**Tip**: you may want to reduce the html file size by compressing the JavaScript code in it. Thus it will be faster to download.

# Mac OS X Part
There's only 2 files needed for Mac OS X part: `GoogleAnalytics.swift` and `GoogleAnalytics.swift`.

## GoogleAnalytics.swift
Good news is, you even don't need to touch this file.

This is the key file to integrate with Google Analytics. If you read the code, you will find it in fact loads the html file in a WebView, and combine the data as parameters for the html.

## GoogleAnalyticsHelper.swift
This class help you easily use Google Analytics.

Don't worry, you only need to update these properties:

- `GAID`
  - The Google Analytics id, e.g., 'UA-12345678-1'. This is the 'id' used as parameter of html file.
- `GAName`
  - The product name, e.g., 'ihosts' for **TODO iHosts Link**. This is the 'name' used as parameter of html file. 
- `PingURL`
  - The full url of gapp.html, e.g., 'http://atjason.com/MacGoogleAnalytics/gapp.html' mentioned above, or the url you deployed.
- `PingTimeInterval`
  - By default it's 6h. It means telling Google Analytics every 6h that 'hey, I'm alive'. This will help Google Analytics to calculate the active users.

# Demo Project Using Swift
How to integrate MacGoogleAnalytics in your project? Just put the `GoogleAnalytics.swift` and `GoogleAnalyticsHelper.swift` in your project.

Then, you need to start Google Analytics when app finished launching, stop it when app will terminate.

```swift
func applicationDidFinishLaunching(aNotification: NSNotification) {    
  GAHelper.startGoogleAnalytics()
}
  
func applicationWillTerminate(notification: NSNotification) {
  GAHelper.stopGoogleAnalytics()
}
```

The main usage of Google Analytics is to send event. How to send the event? Just as simple as following code.

```swift
GA.sendEvent("menu", event: "click", label: "rate")
```

That's all.

## Work With HTTP
When run your project with MacGoogleAnalytics, you may meet this error:

*App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.*

Apple disable http access by default for security reason. If you really need to use http, could manually allow it. Open `Info.plist`, and add the following lines:

```swift
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

Please keep in mind that this solution should be your last resort. You’d ideally want to enable HTTPS on your service, or next, whitelist domains on which you want HTTP and if none of this is possible, then use this approach.

# Demo Project Using Objective C
TODO

# View Data in Google Analytics Site
After data are collected, you can view them in Google Analytics as normal: [https://analytics.google.com/analytics/web/](https://analytics.google.com/analytics/web/). During debug, you can also check whether it works or not in 'Real-Time'.

Just give a tip for OS X version. In the demo app using swift, it collect event of `options > option_a > yes or no`. You may want to know, how many users enable this option in OS X 10.10 and how many for 10.11. How to do it?

Open the `Behavior > Events > Top Events`, select `options > option_a`. Here you should be able to see all the events. Then add a new custom Segment, in `Technology > Operating System Version`, add *contains* '10.10', save it as 'OS X 10.10'. Add another Segment for 'OS X 10.11'.

![1747211](http://p.appsites.io/2016-05-14-1747211.jpg)

And then, apply the Segments, it could distinguish the data of OS X 10.10 or 10.11.

![1750021](http://p.appsites.io/2016-05-14-1750021.jpg)

# Release on Mac App Store
Yes, this way could be released on Mac App Store. In fact, these of my apps have already released on Mac App Store.

- [iHosts](http://ex.toolinbox.net/ga/url.html?utm_medium=ihosts&utm_source=GitHub&id=UA-26569268-10&url=https%3a%2f%2fitunes.apple.com%2fapp%2fid1102004240%3fls%3d1%26mt%3d12)
- [Daily Clipboard](http://ex.toolinbox.net/ga/url.html?utm_medium=clip&utm_source=GitHub&id=UA-26569268-10&url=https%3a%2f%2fitunes.apple.com%2fapp%2fid1056935452%3fls%3d1%26mt%3d12)
- [Attention Timer](http://ex.toolinbox.net/ga/url.html?utm_medium=timer&utm_source=GitHub&id=UA-26569268-10&url=https%3a%2f%2fitunes.apple.com%2fapp%2fid1062139745%3fls%3d1%26mt%3d12)

## Show Your Product
If your product using MacGoogleAnalytics and you'd like to share it here, pull requests welcome :)

# License
MacGoogleAnalytics is licensed under the terms of the MIT license. Just feel free to use it :)

# Donate
If you think Mac Google Analytics is helpful for you, welcome to [donate](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=quietjason%40gmail%2ecom&lc=US&item_name=Mac%20Google%20Analytics&button_subtype=services&currency_code=USD&bn=PP%2dBuyNowBF%3abtn_buynow_SM%2egif%3aNonHosted) :)


