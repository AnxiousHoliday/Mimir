# Mimir
## Logging framework for high usage iOS Apps

<!-- [![CI Status](https://img.shields.io/travis/amereid/Mimir.svg?style=flat)](https://travis-ci.org/amereid/Mimir) -->
[![Version](https://img.shields.io/cocoapods/v/Mimir.svg?style=flat)](https://cocoapods.org/pods/Mimir)
[![License](https://img.shields.io/cocoapods/l/Mimir.svg?style=flat)](https://cocoapods.org/pods/Mimir)
[![Platform](https://img.shields.io/cocoapods/p/Mimir.svg?style=flat)](https://cocoapods.org/pods/Mimir)

## Overview
Mimir is a logging framework (Swift & Objective-C) that is intended for use in high usage apps that log extensively and would like to keep as much logging record as possible all while using the least amount of disk space. 

Unlike other logging frameworks, Mimir logs to text files but tries to maintain as much logging info as possible while using the least amount of disk space.

## Use Case

This framework is intended for apps that:

* log extremely frequently
* log server responses that take up a lot of space in conventional logging mechanisms
* send their logs to developers remotely
* are very bandwidth conscious

Logs are also printed to console.

## How it works

Mimir does this by creating 2 text files:

* truncated text file
* extended text file

Mimir starts out by filling up the extended logs text file until it reaches a certain file size. 
Once the extended logs file is full, the oldest logs are removed from the end of the extended logs file and are moved to the truncated file and then truncated accordingly. 

This mechanism guarantees that the earliest log messages are logged fully while older log messages are truncated.

## Log Levels

There are several different log levels for you to use:

* 🟡 trace
* 🟢 verbose
* 🔵 debug
* 🟣 info
* 🟠 warning
* 🔴 error

## Log Sample

Logging automatically adds the following for each log message:

* Log level
* File name
* Function name
* Line number
* Log message (if not trace)

```ruby
🟡 18:30:15.697 TRACE [File->SwiftExampleViewController.swift] (Func->mimirTestButtonTapped(_:)) [Line->29]
🟢 18:30:15.699 VERBOSE [File->SwiftExampleViewController.swift] (Func->mimirTestButtonTapped(_:)) [Line->30]: "This is a verbose log"
🔵 18:30:15.699 DEBUG [File->SwiftExampleViewController.swift] (Func->mimirTestButtonTapped(_:)) [Line->31]: "This is a debug log"
🟣 18:30:15.699 INFO [File->SwiftExampleViewController.swift] (Func->mimirTestButtonTapped(_:)) [Line->32]: "This is a info log"
🟠 18:30:15.699 WARNING [File->SwiftExampleViewController.swift] (Func->mimirTestButtonTapped(_:)) [Line->33]: "This is a warning log"
🔴 18:30:15.699 ERROR [File->SwiftExampleViewController.swift] (Func->mimirTestButtonTapped(_:)) [Line->34]: "This is a error log"
```

# Usage - Swift

## Setup

Setting up Mimir should happen before logging begins, preferrably at the beginning of didFinishLaunchingWithOptions in the AppDelegate.

```ruby
import Mimir // Do not forget this

let fileDestination = MMRFileDestination(nameOfFile: "sample")
Mimir.addDestination(fileDestination)

let consoleDestination = MMRConsoleDestination()
Mimir.addDestination(consoleDestination)
```

The fileDestination can also be customized:

* maxExtendedSize -> max size of extended logs file (Default 5MB)
* maxTruncatedSize -> max size of truncated logs file (Default 3MB)
* maxTruncatedLogLength -> max length of log message that is moved to truncated logs file (Default 1024)
* extraPercentageToStartDeletion -> buffer for when to delete overflowing logs (Default 0.2)

Example:

```ruby
let fileDestination = MMRFileDestination(nameOfFile: "sample")

fileDestination.maxExtendedSize = 6_000_000
fileDestination.maxTruncatedSize = 4_000_000
fileDestination.maxTruncatedLogLength = 1_000
fileDestination.extraPercentageToStartDeletion = 0.4

Mimir.addDestination(fileDestination)
```

## Basic Logging

```ruby
import Mimir // Do not forget this

Mimir.verbose("This is a verbose log")
Mimir.debug("This is a debug log")
Mimir.info("This is a info log")
Mimir.warning("This is a warning log")
Mimir.error("This is a error log")
```

## Fetching Logs

Fetching logs is very easy and straightforward and there are multiple ways to fetch the logs:

```ruby
import Mimir // Do not forget this

// Gets an array of URL objects for the logs text files
let _ = Mimir.getLogsPaths()

// Gets the path of the folder containing the logs as a String
let _ = Mimir.getLogsDirectoryPath()

// Gets logs as a string while limiting number of bytes
let _ = Mimir.getLogsAsString(limitInBytes: 500)
```

# Usage - Objective-C

## Setup

Setting up Mimir should happen before logging begins, preferrably at the beginning of didFinishLaunchingWithOptions in the AppDelegate.

```ruby
#import <Mimir/Mimir-Swift.h> // Do not forget this

MMRFileDestination* fileDestination = [[MMRFileDestination alloc] initWithNameOfFile:@"sample"];
[Mimir addDestination:fileDestination];

MMRConsoleDestination *consoleDestintion = [[MMRConsoleDestination alloc] init];
[Mimir addDestination:consoleDestintion];
```

The fileDestination can also be customized:

* maxExtendedSize -> max size of extended logs file (Default 5MB)
* maxTruncatedSize -> max size of truncated logs file (Default 3MB)
* maxTruncatedLogLength -> max length of log message that is moved to truncated logs file (Default 1024)
* extraPercentageToStartDeletion -> buffer for when to delete overflowing logs (Default 0.2)

Example:

```ruby
MMRFileDestination* fileDestination = [[MMRFileDestination alloc] initWithNameOfFile:@"sample"];

fileDestination.maxExtendedSize = 6000000;
fileDestination.maxTruncatedSize = 4000000;
fileDestination.maxTruncatedLogLength = 1000;
fileDestination.extraPercentageToStartDeletion = 0.4;

[Mimir addDestination:fileDestination];
```

## Basic Logging

The Objective-C functions for logging are macros and are used as such:

```ruby
#import <Mimir/MimirObjC.h>

MimirTrace();
MimirVerbose(@"This is a verbose log");
MimirDebug(@"This is a debug log");
MimirInfo(@"This is a info log");
MimirWarning(@"This is a warning log");
MimirError(@"This is a error log");
```

Formatting log in objective is quite easy using the macros as well:

```ruby
MimirVerbose(@"This is a %@'s verbose log", @"Amer's");

🟢 18:42:56.702 VERBOSE [File->ObjCExampleViewController.m] (Func->mimirTestButtonTapped:) [Line->36]: "This is a Amer's's verbose log"
```

## Fetching Logs

Fetching logs is very easy and straightforward and there are multiple ways to fetch the logs:

```ruby
#import <Mimir/MimirObjC.h> // Do not forget this

// Gets an array of URL objects for the logs text files
NSArray<NSURL*> *logsPaths = [Mimir getLogsPaths];

// Gets the path of the folder containing the logs as a String
NSString* logsDirectoryPath = [Mimir getLogsDirectoryPath];

// Gets logs as a string while limiting number of bytes
NSString* truncatedLogsString = [Mimir getLogsAsStringWithLimitInBytes:500];
```

## Notes

This framework is still in the early phases and will keep evolving. 

If you use this framework and happen to like it, feel free to let me know 😊

## Installation

Mimir is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Mimir'
```

## Author

Amer Eid, amereid92@gmail.com

## License

Mimir is available under the MIT license. See the LICENSE file for more info.
