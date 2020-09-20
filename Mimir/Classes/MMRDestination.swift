//
//  MMRLogsTarget.swift
//  MimirBenchmark
//
//  Created by Amer Eid on 4/8/19.
//  Copyright © 2019 Amer Eid. All rights reserved.
//

import UIKit
protocol MMRLoggingProtocol {
    func log(level: MimirLogLeveL, msg: String?, thread: String, file: String, function: String, line: Int, preventTruncation: Bool)
}

public class MMRDestination: NSObject, MMRLoggingProtocol {
    var defaultHashValue: Int {return 0}
    var queue: DispatchQueue!
    let dateFormatter = DateFormatter()
    
    public override init() {
        super.init()
        let queueLabel = "mimir-queue-" + NSUUID().uuidString
        queue = DispatchQueue(label: queueLabel, target: queue)
    }
    
    func log(level: MimirLogLeveL, msg: String?, thread: String, file: String, function: String, line: Int, preventTruncation: Bool) {}
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.defaultHashValue)
        return hasher.finalize()
    }
    
    static func == (lhs: MMRDestination, rhs: MMRDestination) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension MMRDestination {
    func formatMessage(level: MimirLogLeveL, msg: String?, thread: String, file: String, function: String, line: Int) -> String {
        let levelIcon:String = level.icon
        let dateString:String = dateFormatter.string(from: Date())
        let levelString:String = level.stringValue
        let lineString:String = String(line)
        let text:String = "\(levelIcon) \(dateString) \(levelString) [File->\(file)] (Func->\(function)) [Line->\(lineString)]: \"\(msg ?? "ENTRY")\""
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
