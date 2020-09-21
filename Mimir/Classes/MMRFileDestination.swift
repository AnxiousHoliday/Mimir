//
//  MMRFileDestination.swift
//  MimirBenchmark
//
//  Created by Amer Eid on 4/8/19.
//  Copyright © 2019 Amer Eid. All rights reserved.
//

import UIKit

class MMRFileTarget {
    private let nameOfTarget: String
    let extendedLogsURL: URL
    let truncLogsURL: URL
    private static let extendedSuffix:String = "-extended.log"
    private static let truncSuffix:String = "-trunc.log"
    
    init(nameOfTarget: String, parentDirURL: URL) {
        self.nameOfTarget = nameOfTarget
        self.extendedLogsURL = parentDirURL.appendingPathComponent(nameOfTarget + MMRFileTarget.extendedSuffix, isDirectory: false)
        self.truncLogsURL = parentDirURL.appendingPathComponent(nameOfTarget + MMRFileTarget.truncSuffix, isDirectory: false)
    }
}

public class MMRFileDestination: MMRDestination {
    override var defaultHashValue: Int { return 2 }
    
    private(set) var fileTarget: MMRFileTarget!
    private let dateFormat: String = "E, d MMM yyyy HH:mm:ss.SSS"
    private let fileManager = FileManager.default

    private var fileHandleExtended: FileHandle?
    private var fileHandleTruncated: FileHandle?
    
    private let splitter: String = "<m>"
    private let preventTruncationEndText: String = "<f>"

    // Can be modified when setting up an instance of MMRFileDestination
    @objc var maxExtendedSize: Int = 5_000_000 // Each character is 1 byte
    @objc var maxTruncatedSize: Int = 3_000_000
    @objc var maxTruncatedLogLength: Int = 1024
    @objc var extraPercentageToStartDeletion: Float = 0.2
    
    private var _currentTruncatedLogsSize:Int64?
    private var currentTruncatedLogsSize:Int64 {
        get { return calculateSizeOfLogsFile(realLogsFileSize: &_currentTruncatedLogsSize, logsFileURL: fileTarget.truncLogsURL) }
        set { _currentTruncatedLogsSize = newValue }
    }
    
    private var _currentExtendedLogsSize:Int64?
    private var currentExtendedLogsSize:Int64 {
        get { return calculateSizeOfLogsFile(realLogsFileSize: &_currentExtendedLogsSize, logsFileURL: fileTarget.extendedLogsURL) }
        set { _currentExtendedLogsSize = newValue }
    }
    
    // This is added in order to avoid always checking file size of logs using fileManager and instead calculating it in memory
    // (every time a log is added, we manually add its size to total etc.)
    private func calculateSizeOfLogsFile(realLogsFileSize: inout Int64?, logsFileURL: URL) -> Int64 {
        if realLogsFileSize != nil {
            return realLogsFileSize!
        } else {
            realLogsFileSize = Int64(bitPattern: sizeForLocalFilePath(filePath: logsFileURL.path))
            return realLogsFileSize!
        }
    }
    
    static let mimirLogsFolderURL: URL? = {
        guard let cachesDirectory:URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("Mimir: Error getting cachesDirectory")
            return nil
        }
        let baseURL = cachesDirectory.appendingPathComponent("Mimir")
        do {
            try FileManager.default.createDirectory(atPath: baseURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Mimir: Error creating directory: \(error.localizedDescription)")
            return nil
        }
        return baseURL
    }()

    @objc public init(nameOfFile: String) {
        if let mimirLogsFolderURL = MMRFileDestination.mimirLogsFolderURL {
            fileTarget = MMRFileTarget(nameOfTarget: nameOfFile, parentDirURL: mimirLogsFolderURL)
        }
        print("Mimir: Logs location -> \(MMRFileDestination.mimirLogsFolderURL?.absoluteString ?? "Error getting logs folder url")")
        super.init()
        dateFormatter.dateFormat = dateFormat
    }
    
    deinit {
        fileHandleExtended?.closeFile()
        fileHandleTruncated?.closeFile()
    }
    
    override func log(level: MimirLogLeveL, msg: String?, thread: String, file: String, function: String, line: Int, preventTruncation: Bool) {
        let formattedString = formatMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        let wroteToExtendedLogsFile = writeToExtendedLogsFile(logString: formattedString, preventsTruncation: preventTruncation)
        guard wroteToExtendedLogsFile == true else {
            return
        }
        trimExtendedLogsFileIfNecessary()
    }
    
    @discardableResult
    private func writeToExtendedLogsFile(logString: String, preventsTruncation: Bool) -> Bool {
        let extendedLogsFileURL = fileTarget.extendedLogsURL
        var logLine = logString
        if preventsTruncation == true {
            logLine = logString + preventTruncationEndText
        }
        logLine = logLine + splitter + "\n"
        do {
            if fileManager.fileExists(atPath: extendedLogsFileURL.path) == false {
                fileHandleExtended = nil
                try logLine.write(to: extendedLogsFileURL, atomically: true, encoding: .utf8)
                currentExtendedLogsSize = Int64(logLine.count)
                if #available(iOS 10.0, watchOS 3.0, *) {
                    var attributes = try fileManager.attributesOfItem(atPath: extendedLogsFileURL.path)
                    attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                    try fileManager.setAttributes(attributes, ofItemAtPath: extendedLogsFileURL.path)
                }
            } else {
                if fileHandleExtended == nil {
                    fileHandleExtended = try FileHandle(forWritingTo: extendedLogsFileURL as URL)
                }
                if let fileHandleExtended = fileHandleExtended {
                    _ = fileHandleExtended.seekToEndOfFile()
                    if let data = logLine.data(using: String.Encoding.utf8) {
                        fileHandleExtended.write(data)
                         currentExtendedLogsSize = currentExtendedLogsSize + Int64(data.count)
                    }
                } else {
                    print("Mimir: fileHandleExtended was nil in writeToExtendedLogsFile.")
                    return false
                }
            }
            return true
        } catch {
            print("Mimir: File Destination could not write to file \(extendedLogsFileURL).")
            return false
        }
    }
    
    @discardableResult
    private func trimExtendedLogsFileIfNecessary() -> Bool {
        let extendedLogsFileURL = fileTarget.extendedLogsURL
        let extendedLogsFileMaxSize:Float = Float(maxExtendedSize)
        let trimmingOffset:UInt64 = UInt64(extraPercentageToStartDeletion * extendedLogsFileMaxSize + extendedLogsFileMaxSize)
        guard currentExtendedLogsSize > trimmingOffset else {
            return false
        }
        do {
            let data = try Data(contentsOf: extendedLogsFileURL, options: .dataReadingMapped)
            let splitterData:Data = Data(splitter.utf8)
            let cuttOffPos = data.count - maxExtendedSize
            guard cuttOffPos > 0 else {
                return false
            }
            // Get range of first "<m>" after cuttOffPos
            let searchRange = data.index(data.startIndex, offsetBy: cuttOffPos)..<data.endIndex
            guard let range = data.range(of: splitterData, options: [], in: searchRange) else {
                return false
            }
            
            // Trim extendedData from the first "<m>" cuttOffPos till the end
            let indexOfSplitter = range.endIndex
            let indexEnd = data.endIndex
            let trimmedExtendedData = data.subdata(in: indexOfSplitter..<indexEnd)
            if fileHandleExtended == nil {
                fileHandleExtended = try FileHandle(forWritingTo: extendedLogsFileURL as URL)
            }
            if let fileHandleExtended = fileHandleExtended {
                fileHandleExtended.seek(toFileOffset: 0)
                fileHandleExtended.write(trimmedExtendedData)
                fileHandleExtended.truncateFile(atOffset: UInt64(trimmedExtendedData.count))
                currentExtendedLogsSize = Int64(trimmedExtendedData.count)
            }
            
            let dataToAddToTruncated = data.subdata(in: data.startIndex..<indexOfSplitter)
            addToTruncatedLogsFile(data: dataToAddToTruncated)
            return true
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
    }
    
    private func addToTruncatedLogsFile(data: Data?) {
        let truncLogsFileURL = fileTarget.truncLogsURL
        guard let data = data else {
            return
        }
        guard let logsToAdd = String(data: data, encoding: String.Encoding.utf8) as String? else {
            return
        }
        var logsArray = logsToAdd.components(separatedBy: splitter)
        for (index, logString) in logsArray.enumerated() {
            guard logString.count > maxTruncatedLogLength && logString.hasSuffix(preventTruncationEndText) == false else {
                continue
            }
            logsArray[index] = logString.trunc(length: maxTruncatedLogLength, trailing: "...\"")
        }
        let finalTruncatedStringToAdd = logsArray.joined(separator: splitter)
        do {
            if fileManager.fileExists(atPath: truncLogsFileURL.path) == false {
                fileHandleTruncated = nil
                try finalTruncatedStringToAdd.write(to: truncLogsFileURL, atomically: true, encoding: .utf8)
                currentExtendedLogsSize = Int64(finalTruncatedStringToAdd.count)
                if #available(iOS 10.0, watchOS 3.0, *) {
                    var attributes = try fileManager.attributesOfItem(atPath: truncLogsFileURL.path)
                    attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                    try fileManager.setAttributes(attributes, ofItemAtPath: truncLogsFileURL.path)
                }
            } else {
                if fileHandleTruncated == nil {
                    fileHandleTruncated = try FileHandle(forWritingTo: truncLogsFileURL as URL)
                }
                if let fileHandleTruncated = fileHandleTruncated {
                    _ = fileHandleTruncated.seekToEndOfFile()
                    if let data = finalTruncatedStringToAdd.data(using: String.Encoding.utf8) {
                        fileHandleTruncated.write(data)
                        currentTruncatedLogsSize = currentTruncatedLogsSize + Int64(data.count)
                    }
                }
            }

            let truncatedLogsFileMaxSize:Float = Float(maxTruncatedSize)
            let trimmingOffset:UInt64 = UInt64(extraPercentageToStartDeletion * truncatedLogsFileMaxSize + truncatedLogsFileMaxSize)
            if currentTruncatedLogsSize > trimmingOffset {
                let data = try Data(contentsOf: truncLogsFileURL, options: .dataReadingMapped)
                let splitterData:Data = Data(splitter.utf8)
                let cuttOffPos = data.count - maxTruncatedSize
                guard cuttOffPos > 0 else {
                    return
                }
                // Get range of first "<m>" after cuttOffPos
                let searchRange = data.index(data.startIndex, offsetBy: cuttOffPos)..<data.endIndex
                guard let range = data.range(of: splitterData, options: [], in: searchRange) else {
                    return
                }
                
                // Trim extendedData from the first "<m>" cuttOffPos till the end
                let indexOfSplitter = range.endIndex
                let indexEnd = data.endIndex
                let trimmedTruncatedData = data.subdata(in: indexOfSplitter..<indexEnd)
                if fileHandleTruncated == nil {
                    fileHandleTruncated = try FileHandle(forWritingTo: truncLogsFileURL as URL)
                }
                if let fileHandleTruncated = fileHandleTruncated {
                    fileHandleTruncated.seek(toFileOffset: 0)
                    fileHandleTruncated.write(trimmedTruncatedData)
                    fileHandleTruncated.truncateFile(atOffset: UInt64(trimmedTruncatedData.count))
                    currentTruncatedLogsSize = Int64(trimmedTruncatedData.count)
                }
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
     func getLogsAsString(limitInBytes: Int) -> String? {
        let extendedLogsFileURL = fileTarget.extendedLogsURL
        do {
            let text = try String(contentsOf: extendedLogsFileURL, encoding: .utf8)
            return String(text.suffix(limitInBytes))
        } catch {
            print("Mimir: Failed to get file attributes for local path: \(extendedLogsFileURL) with error: \(error)")
            return nil
        }
    }
    
    private func sizeForLocalFilePath(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try fileManager.attributesOfItem(atPath: filePath)
            guard let fileSize = fileAttributes[FileAttributeKey.size] else {
                print("Mimir: Failed to get a size attribute from path: \(filePath)")
                return 0
            }
            return (fileSize as! NSNumber).uint64Value
        } catch {
            print("Mimir: Failed to get file attributes for local path: \(filePath) with error: \(error)")
            return 0
        }
    }
}

fileprivate extension String {
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}
