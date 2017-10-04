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
- iOS 10.0+
- Xcode 8.2+
- Swift 3.0+

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
