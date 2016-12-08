//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>

#import "DBMessage.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Message : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (void)updateStatus:(NSString *)groupId messageId:(NSString *)messageId;

+ (void)deleteItem:(NSString *)groupId messageId:(NSString *)messageId;

+ (void)deleteItem:(DBMessage *)dbmessage;

@end

