# OpenALPRSwift
OpenALPRSwift is an iOS Framework for the open source OpenALPR *Automatic License Plate Recognition* library http://www.openalpr.com. It can be used in Swift and Objective-C

The library analyzes images and video streams to identify license plates.  The output is the text representation of any license plate characters.

Current version is using precompiled Frameworks from [cardash](https://github.com/cardash/react-native-openalpr/tree/master/ios/Frameworks):
* leptonica.framework
* tesseract.framework

openalpr.framework compiled from v2.3.0 and dependency pod v3.1.0.1 for [OpenCV](https://cocoapods.org/?q=opencv)

# Requirements
* iOS 9+

# Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.3.0.beta.2+ is required to build OpenALPRSwift 1.0.0+.

To integrate OpenALPRSwift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'OpenALPRSwift', '~> 2.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```
If you get an error complaining about "transitive dependencies" then put this in your Podfile

```
pre_install do |installer|
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
```

# Usage

`import OpenALPRSwift`
in your class and then
```
    let imagePath = Bundle.main.path(forResource: "dk_vb33742", ofType: "jpg")
    let alprScanner = OAScanner(country: "eu", patternRegion: "dk")
    alprScanner?.scanImage(atPath: imagePath, onSuccess: { (plates) in
        plates?.forEach({ (plate) in
            print("result: \(plate.number)")
        })
    }, onFailure: { (error) in
        print("error: \(error?.localizedDescription)")
    })
```
or you can pass a `UIImage` as well 

# Options

### `country`
Specifies which OpenALPR config file to load, corresponding to the country whose plates you wish to recognize. Currently supported values are: [`au`, `auwide`, `br`, `eu`, `fr`, `gb`, `kr`, `kr2`, `mx`, `sg`, `us`, `vn2`]

### `region`
Specifies which plate pattern to look for e.g. `dk` for Denmark or `al` for Alabama. Complete list of patterns is available under runtime_data/postprocess/*.patterns

Documentation
---------------

Detailed documentation is available at [doc.openalpr.com](http://doc.openalpr.com/)

License
-------

GPLv3
http://www.gnu.org/licenses/gpl-3.0.html

# Credits
* [iOS](https://github.com/twelve17/openalpr-ios)
* [iOS React Native](https://github.com/cardash/react-native-openalpr)

