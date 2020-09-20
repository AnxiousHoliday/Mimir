//
//  MMRConsoleDestination.swift
//  MimirBenchmark
//
//  Created by Amer Eid on 4/8/19.
//  Copyright © 2019 Amer Eid. All rights reserved.
//

import UIKit

public class MMRConsoleDestination: MMRDestination {
    private let dateFormat:String = "HH:mm:ss.SSS"
    override var defaultHashValue: Int { return 1 }
    
    public override init() {
        super.init()
        dateFormatter.dateFormat = dateFormat
    }
    override func log(level: MimirLogLeveL, msg: String?, thread: String, file: String, function: String, line: Int, preventTruncation: Bool) {
        let formattedString = formatMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        print(formattedString)
    }
}
