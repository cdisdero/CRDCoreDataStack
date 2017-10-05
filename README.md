# CRDCoreDataStack
[![Build Status](https://travis-ci.org/cdisdero/CRDCoreDataStack.svg?branch=master)](https://travis-ci.org/cdisdero/CRDCoreDataStack)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CRDCoreDataStack.svg)](https://img.shields.io/cocoapods/v/CRDCoreDataStack.svg)
[![Platform](https://img.shields.io/cocoapods/p/CRDCoreDataStack.svg?style=flat)](http://cocoadocs.org/docsets/CRDCoreDataStack)

Simple straightforward Swift-based Core Data stack.

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Conclusion](#conclusion)
- [License](#license)

## Overview
I got tired of adding the same boilerplate Core Data stack code to every Swift app I created, so I just put together this small framework to encapsulate the code for more simple reuse.

## Requirements
- iOS 10.0+ / macOS 10.11+ / watchOS 3.0+ / tvOS 9.0+
- Xcode 9.0+
- Swift 4.0+

## Installation
You can simply copy the following files from the GitHub tree into your project:

  * `CRDCoreDataStack.swift`
    - Swift-based class to encapsulate all the necessary Core Data boilerplate code.

### CocoaPods
Alternatively, you can install it as a Cocoapod

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build CRDCoreDataStack

To integrate CRDCoreDataStack into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
target 'MyApp' do
  use_frameworks!

  # Pods for MyApp
  pod 'CRDCoreDataStack'
end
```

Then, run the following command:

```bash
$ pod install
```
### Carthage
You can use Carthage to add this framework to your project:
1. Add a `Cartfile` to the directory where your xcodeproj file is located.
2. Edit this file to specify the 1.0 release or higher of this framework:
```
github "cdisdero/CRDCoreDataStack" >= 1.0
```
3. Run Carthage to add the framework sources and build this framework:
```
carthage update
```
4. In the General tab of your Xcode project app target, drag and drop the Carthage-built framework for your target type onto the Linked Frameworks and Libraries list at the bottom.  You can find the built framework in your project folder in the subfolder Carthage/Build/[target]/CRDCoreDataStack.framework, where [target] is something like 'iOS', etc.
5. To make sure that the framework is properly stripped of extraneous CPU types for your release app, add the following Run Script build phase to your app target:
```
/usr/local/bin/carthage copy-frameworks
```
This assumes Carthage is installed in `/usr/local/bin` on your system.  Also specify the following Input Files in the same Run Script build phase:
```
$(SRCROOT)/Carthage/Build/iOS/CRDCoreDataStack.framework
```

## Usage
The library is easy to use.  Just import CRDCoreDataStack and create a new object:

```
let coreDataStack = CRDCoreDataStack(modelName, delegate)
```

The modelName parameter is the name of the Core Data xcdatamodeld file.  The second optional delegate parameter is a reference to a class instance that implements the CRDCoreDataStackProtocol, which consists of one function called 'seedDataStore' which allows you to seed the model data store at the appropriate time.

You probably want to store the coreDataStack instance you created above in a central location that is accessible from most all of the code in your app, such as AppDelegate.

Using the CRDCoreDataStack instance, you can access the main NSManagedObjectContext for the model, as well as create private child contexts:

```
let mainContext = coreDataStack.mainManagedObjectContext
let privateContext = coreDataStack.privateChildManagedObjectContext()

```
The process of initializing the Core Data stack can take some time, so there are two Notifications that are thrown depending on whether initialization succeeds or fails after the CRDCoreDataStack initializer is called:

```
CRDCoreDataStack.notificationInitialized
CRDCoreDataStack.notificationInitializedFailed
```

You should wait until you receive the `CRDCoreDataStack.notificationInitialization` before doing anything with the data store.  As an example here is some code that accomplishes this using the `NotificationCenter.default`:

```
NotificationCenter.default.addObserver(forName: Notification.Name(CRDCoreDataStack.notificationInitialized), object: nil, queue: OperationQueue.main) { (notification) in

    do {

        // Create and insert a new data object on a private context.
        let context = self.coreDataStack.privateChildManagedObjectContext()
        let myDataObject = try MyDataObject(context: context)
        myDataObject.name = "Frank"
        
        // Commit the new object to the private context.
        try context.save()

        // Save all private and main context changes to the data store.
        self.coreDataStack.saveChanges(onError: { (error) in

            if let error = error {

                print(error)
            }
        })

    } catch let error {

        print(error)
    }
}

NotificationCenter.default.addObserver(forName: Notification.Name(CRDCoreDataStack.notificationInitializedFailed), object: nil, queue: OperationQueue.main) { (notification) in

    print(notification)
}

```

You can save any changes to the private and main contexts to disk using the saveChanges(onError:) function:

```
coreDataStack.saveChanges { (error) in

   // TODO: report error.
}

```

## Conclusion
I hope this small library/framework is helpful to you in your next Swift project.  I'll be updating as time and inclination permits and of course I welcome all your feedback.

## License
CRDCoreDataStack is released under an Apache 2.0 license. See LICENSE for details.
