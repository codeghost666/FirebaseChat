//
// Copyright (c) 2016 Ryan
//

#import <Realm/Realm.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DBGroup : RLMObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property NSString *objectId;

@property NSString *userId;
@property NSString *name;
@property NSString *picture;
@property NSString *members;

@property BOOL isDeleted;

@property NSTimeInterval createdAt;
@property NSTimeInterval updatedAt;

@end

