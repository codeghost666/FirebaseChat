//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>
 
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Dir : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)application;
+ (NSString *)application:(NSString *)component;
+ (NSString *)application:(NSString *)component1 and:(NSString *)component2;

+ (NSString *)document;
+ (NSString *)document:(NSString *)component;

+ (NSString *)cache;
+ (NSString *)cache:(NSString *)component;

@end

