//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>

#import "DBUser.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface CallHistory : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (void)createItem:(NSString *)userId recipientId:(NSString *)recipientId text:(NSString *)text details:(id<SINCallDetails>)details;

+ (void)deleteItem:(NSString *)objectId;

@end

