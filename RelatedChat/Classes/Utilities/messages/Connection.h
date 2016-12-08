//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Connection : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (strong, nonatomic) Reachability *reachability;

+ (Connection *)shared;

+ (BOOL)isReachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end

