//
//  MimirObjC.h
//  MimirBenchmark
//
//  Created by Amer Eid on 5/3/19.
//  Copyright © 2019 Amer Eid. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MimirTrace() [MimirObjC logWithType:0 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:NO andMessage: nil]
#define MimirVerbose(frmt, ...) [MimirObjC logWithType:1 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:NO andMessage: frmt, ##__VA_ARGS__]
#define MimirDebug(frmt, ...) [MimirObjC logWithType:2 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:NO andMessage: frmt, ##__VA_ARGS__]
#define MimirInfo(frmt, ...) [MimirObjC logWithType:3 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:NO andMessage: frmt, ##__VA_ARGS__]
#define MimirWarning(frmt, ...) [MimirObjC logWithType:4 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:NO andMessage: frmt, ##__VA_ARGS__]
#define MimirError(frmt, ...) [MimirObjC logWithType:5 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:NO andMessage: frmt, ##__VA_ARGS__]

#define MimirVerboseFull(frmt, ...) [MimirObjC logWithType:1 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:YES andMessage: frmt, ##__VA_ARGS__]
#define MimirDebugFull(frmt, ...) [MimirObjC logWithType:2 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:YES andMessage: frmt, ##__VA_ARGS__]
#define MimirInfoFull(frmt, ...) [MimirObjC logWithType:3 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:YES andMessage: frmt, ##__VA_ARGS__]
#define MimirWarningFull(frmt, ...) [MimirObjC logWithType:4 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:YES andMessage: frmt, ##__VA_ARGS__]
#define MimirErrorFull(frmt, ...) [MimirObjC logWithType:5 andFromFile:@__FILE__ andFunction:NSStringFromSelector(_cmd) andLine: __LINE__ andPreventTruncation:YES andMessage: frmt, ##__VA_ARGS__]

@interface MimirObjC : NSObject

+ (void) logWithType:(int) logType andFromFile:(NSString*_Nullable) file andFunction:(NSString*_Nullable) function andLine:(int) line andPreventTruncation:(BOOL) preventTruncation andMessage:(nullable NSString *)format, ...;
@end

