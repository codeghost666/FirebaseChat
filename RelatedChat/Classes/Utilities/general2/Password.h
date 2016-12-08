//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>
 
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Password : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)get:(NSString *)groupId;

+ (void)set:(NSString *)password groupId:(NSString *)groupId;

+ (NSString *)init:(NSString *)groupId;

@end

