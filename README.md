
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
</p>

KeychainWrapper is a light weight swift wrapper for iOS keychain. Makes accessing keychain is exetremely simple as `UserDefaults`.

### KeychainWrapper 101

The simplest use case is using the `default` singleton. Then save and load data as the way of manipulating `UserDefaults`.

```swift
/// Save data
KeychainWrapper.default.set(1, forKey: "key.int.value")
KeychainWrapper.default.set([1, 2, 3], forKey: "key.array.value")
KeychainWrapper.default.set("string value", forKey: "key.string.value")

/// Load data
KeychainWrapper.default.object(of: Int.self, forKey: "key.int.value")
KeychainWrapper.default.object(of: Array.self, forKey: "key.array.value")
KeychainWrapper.default.string(forKey: "key.string.value")
```

All `set` methods return `Bool` to indicate if the data was saved successfully. All getter methods return `T?`, if the data corresponding to `forKey` cannot decoded back to `T`, it returns `nil`.
