//
//  MimirObjC.h
//  MimirBenchmark
//
//  Created by Amer Eid on 5/3/19.
//  Copyright © 2019 Amer Eid. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MimirVerbose(frmt, ...) [MimirObjC logVerboseFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:NO andMessage: frmt, ##__VA_ARGS__]
#define MimirVerboseFull(frmt, ...) [MimirObjC logVerboseFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:YES andMessage: frmt, ##__VA_ARGS__]
#define MimirVerboseEntry() [MimirObjC logVerboseFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:NO andMessage: nil]

@interface MimirObjC : NSObject
+ (void) logVerboseFromFile:(NSString*_Nullable) file andFunction:(NSString*_Nullable) function andLine:(int) line andPreventTruncation:(BOOL) preventTruncation andMessage:(nullable NSString *)format, ...;
@end

