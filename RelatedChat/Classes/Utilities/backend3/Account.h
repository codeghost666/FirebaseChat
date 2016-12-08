//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Account : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (void)add:(NSString *)email password:(NSString *)password;

+ (void)delOne;
+ (void)delAll;

+ (NSInteger)count;

+ (NSArray *)userIds;

+ (NSDictionary *)account:(NSString *)userId;

@end

