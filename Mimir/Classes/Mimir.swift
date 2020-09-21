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
    
    /// function thats logs any string passed to it and sets it to "verbose"
    /// - Parameters:
    ///   - message: string that is logged
    ///   - file:  name of the file that the log was called from
    ///   - function: name of the function that the log was called from
    ///   - line: line number where the log was called from
    ///   - preventTruncation: boolean that determines whether the log message will be truncated when it becomes too old or if it maintains its full length
    public static func verbose(_ message:@escaping @autoclosure () -> Any? = nil, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool = false) {
        _log(level: MimirLogLevels.verbose.level, message: message, file: file, function: function, line: line, preventTruncation: preventTruncation)
    }
    
    @objc public static func objcLog(_ message: String? = nil, file: String = #file, function: String = #function, line: Int = #line, preventTruncation: Bool) {
        _log(level: MimirLogLevels.verbose.level, message: message, file: file, function: function, line: line, preventTruncation: preventTruncation)
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
    case verbose, error
    var level: MimirLogLeveL {
        switch self {
        case .verbose:
            return MimirLogLeveL(rawLevel: 0, stringValue: "VERBOSE", icon: "💜")
        case .error:
            return MimirLogLeveL(rawLevel: 1, stringValue: "ERROR", icon: "❤️")
        }
    }
}

struct MimirLogLeveL {
    typealias RawLevel = Int
    let rawLevel: RawLevel
    let stringValue: String
    let icon: String
}