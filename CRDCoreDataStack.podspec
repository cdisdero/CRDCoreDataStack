#
#  Be sure to run `pod spec lint CRDCoreDataStack.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

s.swift_version = '4.2'
  s.name         = "CRDCoreDataStack"
  s.version      = "1.0.3"
  s.summary      = "Simple straightforward Swift-based Core Data stack framework for iOS, macOS, watchOS, and tvOS"
  s.description  = <<-DESC
I got tired of adding the same boilerplate Core Data stack code to every Swift app I created, so I just put together this small framework to encapsulate the code for more simple reuse.
DESC

  s.homepage     = "https://github.com/cdisdero/CRDCoreDataStack"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.license      = "Apache License, Version 2.0"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.author             = { "Christopher Disdero" => "info@code.chrisdisdero.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source       = { :git => "https://github.com/cdisdero/CRDCoreDataStack.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source_files  = "Shared/*.swift"
s.ios.source_files   = 'CRDCoreDataStack/*.h'
s.osx.source_files   = 'CRDCoreDataStackMac/*.h'
s.watchos.source_files = 'CRDCoreDataStackWatch/*.h'
s.tvos.source_files  = 'CRDCoreDataStackTV/*.h'

end
