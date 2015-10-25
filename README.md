YYCache
==============

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/ibireme/YYCache/master/LICENSE)&nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![Cocoapods](http://img.shields.io/cocoapods/v/YYCache.svg?style=flat)](http://cocoapods.org/?q= YYCache)&nbsp;
[![Cocoapods](http://img.shields.io/cocoapods/p/YYCache.svg?style=flat)](http://cocoapods.org/?q= YYCache)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%206%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)

High performance cache framework for iOS.


Performance
==============

![Memory cache benchmark result](https://raw.github.com/ibireme/YYCache/master/Benchmark/Result_memory.png
)

![Disk benchmark result](https://raw.github.com/ibireme/YYCache/master/Benchmark/Result_disk.png
)

You may [download](http://www.sqlite.org/download.html) and compile the lastest version of sqlite and ignore the libsqlite3.dylib in iOS system to get higher performance.

See `Benchmark/CacheBenchmark.xcodeproj` for more benchmark case.


Features
==============
- **LRU**: Objects can be evicted with least-recently-used algorithm.
- **Limitation**: Cache limitation can be controlled with count, cost, age and free space.
- **Compatibility**: The API is similar to `NSCache`, all methods are thread-safe.
- **Memory Cache**
  - **Release Control**: Objects can be released synchronously/asynchronously on main thread or background thread.
  - **Automatically Clear**: It can be configured to automatically evict objects when receive memory warning or app enter background.
- **Disk Cache**
  - **Customization**: It supports custom archive and unarchive method to store object which does not adopt NSCoding.
  - **Storage Type Control**: It can automatically decide the storage type (sqlite / file) for each object to get
      better performance.


Installation
==============

### Cocoapods

1. Add `pod "YYCache"` to your Podfile.
2. Run `pod install` or `pod update`.
3. Import \<YYCache/YYCache.h\>


### Carthage

1. Add `github "ibireme/YYCache"` to your Cartfile.
2. Run `carthage update --platform ios` and add the framework to your project.
3. Import \<YYCache/YYCache.h\>


### Manually

1. Download all the files in the YYCache subdirectory.
2. Add the source files to your Xcode project.
3. Link with required frameworks:
	* UIKit.framework
	* CoreFoundation.framework
	* QuartzCore.framework
	* sqlite3
4. Import `YYCache.h`.


About
==============
This library supports iOS 6.0 and later.


License
==============
YYCache is provided under the MIT license. See LICENSE file for details.


中文链接
==============
[中文介绍和性能评测](http://blog.ibireme.com/2015/10/26/yycache/)

