//
//  Mimir.swift
//  MimirBenchmark
//
//  Created by Amer Eid on 4/8/19.
//  Copyright © 2019 Amer Eid. All rights reserved.
//

import UIKit

public class Mimir: NSObject {
    private static var destinations: Set<MMRDestination> = Set<MMRDestination>()
    
    @objc public static func addDestination(_ destination: MMRDestination) {
        if destinations.contains(destination) == false {
            destinations.insert(destination)
        }
    }
    
    // trace just logs the file, function and line where it was called from without the need for a log message
    public static func trace(file: String = #file, function: String = #function, line: Int = #line) {
        _log(level: MimirLogLevels.trace.level, message: nil, file: file, function: function, line: line, preventTruncation: true)
    }
    
    public static func verbose(_ message:@escaping @autoclosure () -> Any?, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool = false) {
        _log(level: MimirLogLevels.verbose.level, message: message, file: file, function: function, line: line, preventTruncation: preventTruncation)
    }
    
    public static func debug(_ message:@escaping @autoclosure () -> Any?, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool = false) {
        _log(level: MimirLogLevels.debug.level, message: message, file: file, function: function, line: line, preventTruncation: preventTruncation)
    }
    
    public static func info(_ message:@escaping @autoclosure () -> Any?, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool = false) {
        _log(level: MimirLogLevels.info.level, message: message, file: file, function: function, line: line, preventTruncation: preventTruncation)
    }
    
    public static func warning(_ message:@escaping @autoclosure () -> Any?, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool = false) {
        _log(level: MimirLogLevels.warning.level, message: message, file: file, function: function, line: line, preventTruncation: preventTruncation)
    }
    
    public static func error(_ message:@escaping @autoclosure () -> Any?, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool = false) {
        _log(level: MimirLogLevels.error.level, message: message, file: file, function: function, line: line, preventTruncation: preventTruncation)
    }
    
    @objc public static func objcLog(logType: Int, message: String? = nil, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool) {
        _log(level: MimirLogLevels.getLevel(rawLevel: logType), message: message, file: file, function: function, line: line, preventTruncation: preventTruncation)
    }
    
    private class func _log(level: MimirLogLeveL, message: @escaping @autoclosure () -> Any?, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool) {
        for dest in destinations {
            let msgStr = message() as? String
            dest.queue.async {
                dest.log(level: level, msg: msgStr, thread: threadName(), file: fileNameOfFile(file), function: function, line: line, preventTruncation: preventTruncation)
            }
        }
    }
    
    @objc public static func getLogsDirectoryPath() -> String? {
        return MMRFileDestination.mimirLogsFolderURL?.path
    }
    
    @objc public static func getLogsPaths() -> [URL] {
        var logPaths: [URL] = []
        for case let fileDestination as MMRFileDestination in destinations {
            logPaths.append(fileDestination.fileTarget.extendedLogsURL)
            logPaths.append(fileDestination.fileTarget.truncLogsURL)
        }
        return logPaths
    }
    
    @objc public static func getLogsAsString(limitInBytes: Int) -> String? {
        for destination in destinations {
            if let fileDestination = destination as? MMRFileDestination {
                return fileDestination.getLogsAsString(limitInBytes:limitInBytes)
            }
        }
        return nil
    }
}

fileprivate extension Mimir {
    /// returns the current thread name
    static func threadName() -> String {
        if Thread.isMainThread {
            return ""
        } else {
            let threadName = Thread.current.name
            if let threadName = threadName, !threadName.isEmpty {
                return threadName
            } else {
                return String(format: "%p", Thread.current)
            }
        }
    }
    
    /// returns the filename of a path
    static func fileNameOfFile(_ file: String) -> String {
        let fileParts = file.components(separatedBy: "/")
        if let lastPart = fileParts.last {
            return lastPart
        }
        return ""
    }
}

enum MimirLogLevels {
    case trace, verbose, debug, info, warning, error
    var level: MimirLogLeveL {
        switch self {
        case .trace:
            return MimirLogLeveL(rawLevel: 0, stringValue: "TRACE", icon: "🟡")
        case .verbose:
            return MimirLogLeveL(rawLevel: 1, stringValue: "VERBOSE", icon: "🟢")
        case .debug:
            return MimirLogLeveL(rawLevel: 2, stringValue: "DEBUG", icon: "🔵")
        case .info:
            return MimirLogLeveL(rawLevel: 3, stringValue: "INFO", icon: "🟣")
        case .warning:
            return MimirLogLeveL(rawLevel: 4, stringValue: "WARNING", icon: "🟠")
        case .error:
            return MimirLogLeveL(rawLevel: 5, stringValue: "ERROR", icon: "🔴")
        }
    }
    
    static func getLevel(rawLevel: Int) -> MimirLogLeveL {
        switch rawLevel {
        case 0:
            return MimirLogLevels.trace.level
        case 1:
            return MimirLogLevels.verbose.level
        case 2:
            return MimirLogLevels.debug.level
        case 3:
            return MimirLogLevels.info.level
        case 4:
            return MimirLogLevels.warning.level
        case 5:
            return MimirLogLevels.error.level
        default:
            return MimirLogLevels.verbose.level
        }
    }
}

struct MimirLogLeveL {
    typealias RawLevel = Int
    let rawLevel: RawLevel
    let stringValue: String
    let icon: String
}
