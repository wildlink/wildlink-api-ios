# Wildlink API for iOS
[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
<!--[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)-->
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EZSwiftExtensions.svg)](https://img.shields.io/cocoapods/v/LFAlertController.svg)
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Features
This repository allows you to integrate the following Wildlink functionality into your Swift iOS application.

- [x] Create vanity URLs
- [x] Query vanity URL click statistics
- [x] Query your personal commission information
- [x] Query our merchant database
- [x] Search for a specific merchant by name or ID

## Requirements

- iOS 10.0+
- Xcode 10.2+

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `Wildlink` by adding it to your `Podfile`:

```ruby
use_frameworks!
platform:ios, '10.0'


target 'Wildlink_Example' do
  pod 'Wildlink', '~> 0.1.0'
end
```

Once you've added the cocoapod, run `pod install` to set up your project and open your .xcworkspace in Xcode

#### Manually
1. Download and drop ```Wildlink/Classes/*.swift``` in your project.  
2. Congratulations!  

## Usage example

### Initialize the SDK
Somewhere in your application (We suggest in your AppDelegate:didFinishLaunchingWithOptions function) you need
to call the initialize method on the SDK and set yourself up as the Wildlink delegate:

```swift
Wildlink.shared.delegate = self
Wildlink.shared.initialize(appId: "<yourAppID>", appSecret: "<yourAppSecret", wildlinkDeviceToken: "<existingUserToken>", wildlinkDeviceKey: "<existingUserKey>")
```

#### Full example AppDelegate implementation

```swift
import UIKit
import Wildlink

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //initialize wildlink
        Wildlink.shared.delegate = self
        let defaults = UserDefaults.standard
        Wildlink.shared.initialize(appId: "<yourAppID>", appSecret: "<yourAppSecret", wildlinkDeviceToken: defaults.string(forKey: "wildlinkDeviceToken"), wildlinkDeviceKey: defaults.string(forKey: "wildlinkDeviceKey"))

        return true
    }
    
    ...
    
}

extension AppDelegate : WildlinkDelegate {
    func didReceive(deviceKey: String) {
        let defaults = UserDefaults.standard
        defaults.set(deviceKey, forKey: "wildlinkDeviceKey")
    }

    func didReceive(deviceToken: String) {
        let defaults = UserDefaults.standard
        defaults.set(deviceToken, forKey: "wildlinkDeviceToken")
    }

    func didReceive(deviceId: String) {
        let defaults = UserDefaults.standard
        defaults.set(deviceId, forKey: "wildlinkDeviceId")
    }
}
```

In the above example, you'll notice that we're using NSUserDefaults to store and retrieve the device tokens and keys returned by Wildlink
as part of conforming to the WildlinkDelegate protocol. Other requests from the Wildlink SDK are handled via completion handlers as shown
below.

#### Request things from the SDK
Once you've initialized the SDK to identify your application and register the device it's running on, you can begin making requests. 

##### Request a Vanity URL
```swift
import Wildlink
Wildlink.shared.createVanityURL(from: urlOutlet.text) { (url, error) in
    // do something interesting with the result
}
```

##### Request your click statistics
```swift
import Wildlink
//get the hourly results of your clicks for the last week
Wildlink.shared.getClickStats(from: Date(timeIntervalSinceNow: -604800), with: .hour, completion: { (results, error) in
    // do something interesting with the result
})
```

##### Request your commission statistics
```swift
import Wildlink
Wildlink.shared.getCommissionSummary({ (stats, error) in
    // do something interesting with the result
})
```

##### Get details about a specific merchant
```swift
import Wildlink
Wildlink.shared.getMerchantByID("5476062", { (merchant, error) in
    // do something interesting with the result
})
```

##### Search our merchant listings
```swift
import Wildlink
//this example lists *all* of our merchants
Wildlink.shared.searchMerchants(ids: [], names: [], q: nil, disabled: nil, featured: true, sortBy: nil, sortOrder: nil, limit: nil, { (merchants, error) in
    // do something interesting with the result
})
```

## Contribute

We would love for you to contribution to **Wildlink**, check the ``LICENSE`` file for more info.

## Meta

© Copyright 2019 Wildfire Systems, Inc.

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/wildlink/wildlink-api-ios](https://github.com/wildlink/)

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
