//
// Copyright (c) 2016 Ryan
//

#import <Realm/Realm.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DBRecent : RLMObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property NSString *objectId;

@property NSString *userId;
@property NSString *groupId;

@property NSString *initials;
@property NSString *picture;
@property NSString *description;
@property NSString *members;
@property NSString *password;
@property NSString *type;

@property NSInteger counter;
@property NSString *lastMessage;
@property NSTimeInterval lastMessageDate;

@property BOOL isArchived;
@property BOOL isDeleted;

@property NSTimeInterval createdAt;
@property NSTimeInterval updatedAt;

@end

