
<p align="center">
<img src="https://github.com/puretears/KeychainWrapper/blob/master/banner@2x.jpg" alt="KeychainWrapper" title="KeychainWrapper" width="555"/>
</p>

<p align="center">
<a href="https://github.com/puretears/KeychainWrapper">
<img src="https://travis-ci.org/puretears/KeychainWrapper.svg?branch=master">
</a>
<a href="https://codecov.io/gh/puretears/KeychainWrapper">
<img src="https://codecov.io/gh/puretears/KeychainWrapper/branch/master/graph/badge.svg" />
</a>
<a href="https://codebeat.co/projects/github-com-puretears-keychainwrapper-master">
<img alt="codebeat badge" src="https://codebeat.co/badges/b28efd16-4690-410c-8497-b985e2490bcc" />
</a>
<a href="https://github.com/Carthage/Carthage/">
<img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat">
</a>
</p>

KeychainWrapper is a light weight swift wrapper for iOS keychain. Makes accessing keychain is exetremely simple as `UserDefaults`. It is motivated by creating the app of [boxueio.com](https://boxueio.com).

## Features

- [x] Fully tested.
- [x] Simple interface.
- [x] Support access group.
- [x] Support accessibility.
- [x] Updated to Swift 5.

### KeychainWrapper 101

The simplest use case is using the `default` singleton. Then save and load data as the way of manipulating `UserDefaults`.

Add values to keychain. All these `set` methods return `Bool` to indicate if the data was saved successfully. If the key already exists, the data will be overritten.

```swift
/// Save data
KeychainWrapper.default.set(1, forKey: "key.int.value")
KeychainWrapper.default.set([1, 2, 3], forKey: "key.array.value")
KeychainWrapper.default.set("string value", forKey: "key.string.value")
```

Retrieve values from keychain. All kinds of getter methods return `T?`, if the data corresponding to `forKey` cannot decoded back to `T`, it returns `nil`.

```swift
/// Load data
KeychainWrapper.default.object(of: Int.self, forKey: "key.int.value")
KeychainWrapper.default.object(of: Array.self, forKey: "key.array.value")
KeychainWrapper.default.string(forKey: "key.string.value")
```

Remove data from keychain. Return `Bool` indicating if the delete was successful.

```swift
KeychainWrapper.default.removeObject(forKey: "key.to.be.deleted")
```

## Customization

### Specify service name

When you use the `default` KeychainWrapper object, all keys are linked to your main bundle identifier as the service name. Howerver, you could change it as follows:

```swift
let serviceName = "Custom.Service.Name"
let myWrapper = KeychainWrapper(serviceName: serviceName)
```

### Specify access group

You may also share keychain items by a customized access group:

```swift
let serviceName = "Custom.Service.Name"
let accessGroup = "Shared.Access.Group"
let myWrapper = KeychainWrapper(serviceName: serviceName, accessGroup: accessGroup)
```

The `default` KeyChainWrapper object do not share any keychain item and its `accessGroup` is `nil`.

### Accessibility

By default, all items saved by `KeychainWrapper` can only be access when the device is unlocked. The `enum KeychainItemAccessibility` gives you a customization point to specify another accessibility level.

```swift
KeychainWrapper.default.set(1, forKey: "key.int.value", withAccessibility: .afterFirstUnlock)
```

> The `kSecAttrAccessibleAlways` and `kSecAttrAccessibleAlwaysThisDeviceOnly` are deprecated by iOS 12.0. So we do not include them in `KeychainItemAccessibility`.

## Installation

To integrate KeychainWrapper into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), speicify the following line in your `Cartfile`:

```shell
github "puretears/KeychainWrapper" ~> 1.0
```

## Requirements

- iOS 10.0+
- Swift 4.0+

## Next Steps

- Cocoapods and SPM support;
- mac OS support;
- iCloud sharing support;
- More detailed granularity of exception heirarchy, instead of using just `false` or `nil` to indicate errors.

## Release History

- 1.0
  * Initial release

## License

KeychainWrapper is released under the MIT license. See LICENSE for details.
