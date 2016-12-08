//
// Copyright (c) 2016 Ryan
//

#import <Realm/Realm.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DBCallHistory : RLMObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property NSString *objectId;

@property NSString *initiatorId;
@property NSString *recipientId;
@property NSString *phoneNumber;

@property NSString *type;
@property NSString *text;

@property NSString *status;
@property NSInteger duration;

@property NSTimeInterval startedAt;
@property NSTimeInterval establishedAt;
@property NSTimeInterval endedAt;

@property BOOL isDeleted;

@property NSTimeInterval createdAt;
@property NSTimeInterval updatedAt;

@end

