//
//  MimirObjC.m
//  MimirBenchmark
//
//  Created by Amer Eid on 5/3/19.
//  Copyright © 2019 Amer Eid. All rights reserved.
//

#import "MimirObjC.h"
#import <Mimir/Mimir-Swift.h>

@implementation MimirObjC

+ (void) logVerboseFromFile:(NSString*_Nullable) file andFunction:(NSString*_Nullable) function andLine:(int) line andPreventTruncation:(BOOL) preventTruncation andMessage:(nullable NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *logMsg;
    if (format) {
        logMsg = [[NSString alloc] initWithFormat:format arguments:args];
    }
    [Mimir objcLog:logMsg file:file function:function line:line preventTruncation:preventTruncation];
    va_end(args);
}

@end
